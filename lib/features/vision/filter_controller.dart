import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

enum FilterType {
  none,
  contrastBrightness,
  histogramEqualization,
  gaussianBlur,
  unsharpMask,
  edgeDetection,
  binaryThreshold,
  medianFilter,
  gammaCorrection,
  fourierTransform,
  inverseFourier,
}

class _FilterArgs {
  final String imagePath;
  final FilterType filterType;
  final double intensity;
  _FilterArgs(this.imagePath, this.filterType, this.intensity);
}

class FilterController {
  Future<Uint8List> applyFilter(String imagePath, FilterType filterType, double intensity) async {
    return await compute(_processImage, _FilterArgs(imagePath, filterType, intensity));
  }

  static Uint8List _processImage(_FilterArgs args) {
    cv.Mat src = cv.imread(args.imagePath, flags: cv.IMREAD_COLOR);
    if (src.isEmpty) {
      src.dispose();
      return Uint8List(0);
    }
    cv.Mat result = cv.Mat.empty();

    try {
      switch (args.filterType) {
        case FilterType.none:
          result = src.clone();
          break;
        case FilterType.contrastBrightness:
          double alpha = 0.5 + (args.intensity * 2.5);
          result = cv.convertScaleAbs(src, alpha: alpha, beta: 10);
          break;
        case FilterType.histogramEqualization:
          cv.Mat gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
          result = cv.equalizeHist(gray);
          gray.dispose();
          break;
        case FilterType.gaussianBlur:
          int k = (args.intensity * 40).toInt();
          if (k % 2 == 0) k += 1;
          result = cv.gaussianBlur(src, (k, k), 0);
          break;
        case FilterType.unsharpMask:
          cv.Mat blur = cv.gaussianBlur(src, (0, 0), 3.0 * args.intensity);
          result = cv.addWeighted(src, 1.5, blur, -0.5, 0);
          blur.dispose();
          break;
        case FilterType.edgeDetection:
          result = cv.canny(src, 100, 200);
          break;
        case FilterType.binaryThreshold:
          cv.Mat grayBin = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
          double threshVal = args.intensity * 255;
          final thresh = cv.threshold(grayBin, threshVal, 255, cv.THRESH_BINARY);
          result = thresh.$2;
          grayBin.dispose();
          break;
        case FilterType.medianFilter:
          int medianK = (args.intensity * 30).toInt();
          if (medianK % 2 == 0) medianK += 1;
          if (medianK < 3) medianK = 3;
          result = cv.medianBlur(src, medianK);
          break;
        case FilterType.gammaCorrection:
          double gamma = 0.1 + (args.intensity * 3.0);
          final lutList = List.generate(256, (i) {
            return (pow(i / 255.0, 1.0 / gamma) * 255.0).toInt().clamp(0, 255);
          });
          cv.Mat lut = cv.Mat.fromList(1, 256, cv.MatType.CV_8UC1, lutList);
          result = cv.LUT(src, lut);
          lut.dispose();
          break;
        case FilterType.fourierTransform:
          cv.Mat grayDft = cv.cvtColor(src, cv.COLOR_BGR2GRAY);

          int m = cv.getOptimalDFTSize(grayDft.rows);
          int n = cv.getOptimalDFTSize(grayDft.cols);

          cv.Mat padded = cv.copyMakeBorder(grayDft, 0, m - grayDft.rows, 0, n - grayDft.cols, cv.BORDER_CONSTANT, value: cv.Scalar());

          cv.Mat paddedF32 = padded.convertTo(cv.MatType.CV_32FC1);

          final planes = cv.VecMat.fromList([paddedF32, cv.Mat.zeros(paddedF32.rows, paddedF32.cols, cv.MatType.CV_32FC1)]);
          cv.Mat complexI = cv.merge(planes);

          cv.Mat dftRes = cv.dft(complexI, flags: cv.DFT_COMPLEX_OUTPUT);

          final resPlanes = cv.split(dftRes);
          cv.Mat mag = cv.magnitude(resPlanes[0], resPlanes[1]);

          cv.Mat matOnes = cv.Mat.ones(mag.rows, mag.cols, cv.MatType.CV_32FC1);
          cv.Mat magPlusOne = cv.add(mag, matOnes);

          cv.Mat logMag = cv.log(magPlusOne);

          cv.Mat dst = cv.Mat.empty();
          cv.normalize(logMag, dst, alpha: 0, beta: 255, normType: cv.NORM_MINMAX, dtype: cv.MatType.CV_8UC1.value);
          result = dst.clone();
          dst.dispose();

          grayDft.dispose();
          padded.dispose();
          paddedF32.dispose();
          complexI.dispose();
          dftRes.dispose();
          mag.dispose();
          matOnes.dispose();
          magPlusOne.dispose();
          logMag.dispose();
          planes.dispose();
          resPlanes.dispose();
          break;
        case FilterType.inverseFourier:
          cv.Mat grayDft2 = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
          int m2 = cv.getOptimalDFTSize(grayDft2.rows);
          int n2 = cv.getOptimalDFTSize(grayDft2.cols);
          cv.Mat padded2 = cv.copyMakeBorder(grayDft2, 0, m2 - grayDft2.rows, 0, n2 - grayDft2.cols, cv.BORDER_CONSTANT, value: cv.Scalar());
          cv.Mat floatMat = padded2.convertTo(cv.MatType.CV_32FC1);
          cv.Mat dftRes2 = cv.dft(floatMat, flags: cv.DFT_SCALE | cv.DFT_REAL_OUTPUT);

          cv.Mat dst2 = cv.Mat.empty();
          cv.normalize(dftRes2, dst2, alpha: 0, beta: 255, normType: cv.NORM_MINMAX, dtype: cv.MatType.CV_8UC1.value);
          result = dst2.clone();
          dst2.dispose();

          grayDft2.dispose();
          padded2.dispose();
          floatMat.dispose();
          dftRes2.dispose();
          break;
      }

      final bytes = cv.imencode(".jpg", result).$2;
      result.dispose();
      src.dispose();
      return bytes;
    } catch (e) {
      if (!result.isEmpty) result.dispose();
      src.dispose();
      return Uint8List(0);
    }
  }
}
