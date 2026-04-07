import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'analysis_detail_screen.dart';
import 'assessment_analysis_processing_screen.dart';
import '../main.dart';
import '../theme/app_colors.dart';

class ScanSessionScreen extends StatefulWidget {
  final String patientName;
  final String patientId;

  const ScanSessionScreen({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<ScanSessionScreen> createState() => _ScanSessionScreenState();
}

class _ScanSessionScreenState extends State<ScanSessionScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  bool _isFrontCamera = true;
  final ImagePicker _picker = ImagePicker();
  
  // Scanning state
  bool _isScanning = false;
  double _progress = 0.0;
  int _landmarksFound = 4;

  // Face detection state
  late final FaceDetector _faceDetector;
  bool _isFaceDetected = false;
  bool _isBusy = false;
  int _lastProcessedTimestamp = 0;
  bool _showShutter = false;
  bool _isScanCompleted = false;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: true,
        enableContours: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;
    
    CameraDescription? selectedCamera;
    
    if (_isFrontCamera) {
      selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );
    } else {
      selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras[0],
      );
    }

    // Dispose old controller if exists
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(selectedCamera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    
    if (mounted) {
      _controller!.startImageStream(_processCameraImage);
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isBusy) return;
    
    // Throttle detection to ~5 FPS to save battery/CPU
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessedTimestamp < 200) return;
    _lastProcessedTimestamp = now;

    _processImage(image);
  }

  Future<void> _processImage(CameraImage image) async {
    _isBusy = true;
    
    try {
      final camera = cameras.firstWhere((c) => c.name == _controller!.description.name);
      
      // Calculate rotation
      final sensorOrientation = camera.sensorOrientation;
      final imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      
      Uint8List bytes;
      InputImageFormat inputImageFormat;

      // Handle Android YUV420 or mismatched formats by converting to a clean grayscale NV21-like buffer
      // This is the most compatible way to handle various Android hardware quirks
      if (image.format.raw == 35 || image.planes.length > 1) {
        final int width = image.width;
        final int height = image.height;
        final yPlane = image.planes[0];
        
        // Strip padding - ML Kit works best with tight buffers
        final Uint8List strippedY = Uint8List(width * height);
        for (int y = 0; y < height; y++) {
          strippedY.setRange(
            y * width,
            (y + 1) * width,
            yPlane.bytes,
            y * yPlane.bytesPerRow,
          );
        }

        // Fill UV with neutral 128 for grayscale
        final int uvLength = (width * height / 2).toInt();
        final Uint8List combined = Uint8List(strippedY.length + uvLength);
        combined.setRange(0, strippedY.length, strippedY);
        combined.fillRange(strippedY.length, combined.length, 128);
        
        bytes = combined;
        inputImageFormat = InputImageFormat.nv21;
      } else {
        // iOS BGRA8888 or single plane formats
        bytes = image.planes[0].bytes;
        inputImageFormat = format ?? InputImageFormat.bgra8888;
      }

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: inputImageFormat == InputImageFormat.nv21 ? image.width.toInt() : image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
      final faces = await _faceDetector.processImage(inputImage);
      
      if (mounted) {
        setState(() {
          _isFaceDetected = faces.isNotEmpty;
          if (_isFaceDetected) {
            // Sync landmarks with progress: more progress = more landmarks "discovered"
            const baseLandmarks = 9;
            _landmarksFound = ((baseLandmarks * _progress) + 1).floor().clamp(1, baseLandmarks);
          } else {
            _landmarksFound = 0;
          }
        });
      }
    } catch (e) {
      debugPrint('MLKit Error: $e');
    } finally {
      _isBusy = false;
    }
  }

  void _triggerShutter() {
    if (!mounted) return;
    setState(() => _showShutter = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showShutter = false);
    });
  }

  Future<void> _toggleCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializeCamera();
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentAnalysisProcessingScreen(
            patientName: widget.patientName,
            patientId: widget.patientId,
            imagePath: image.path,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _processScan() async {
    setState(() {
      _isScanning = true;
      _progress = 0.0;
    });
    
    // Simulate scan progress
    for (int i = 0; i <= 100; i += 5) {
      if (!_isScanning || !mounted || _isScanCompleted) break;
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _progress = i / 100;
        });
      }
    }

    if (_isScanning && mounted) {
      _completeScan();
    }
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
      _isProcessing = false;
    });
  }

  Future<void> _completeScan() async {
    if (_isScanCompleted) return;
    setState(() {
      _isScanCompleted = true;
      _isScanning = false;
    });
    _triggerShutter();
    String? imagePath;
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        final XFile file = await _controller!.takePicture();
        imagePath = file.path;
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentAnalysisProcessingScreen(
          patientName: widget.patientName,
          patientId: widget.patientId,
          imagePath: imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.editorialBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.editorialTextPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.editorialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editorialBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.editorialTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Scan',
              style: TextStyle(
                color: AppColors.editorialTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '${widget.patientName.toUpperCase()} • ID: ${widget.patientId}',
              style: const TextStyle(
                color: AppColors.editorialTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.videocam_outlined, color: AppColors.editorialTextPrimary.withOpacity(0.5), size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREVIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.editorialTextPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              // Camera Preview Container
              AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller!),
                      
                      // Status Label (Center)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 140),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (_isFaceDetected ? 'FACE DETECTED' : 'ALIGN FACE IN CENTER').toUpperCase(),
                                style: TextStyle(
                                  color: _isFaceDetected ? AppColors.anxietyLow : Colors.orange,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            if (_isScanning) ...[
                              const SizedBox(height: 12),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'LANDMARKS: $_landmarksFound',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Oval UI Overlay
                      Center(
                        child: Container(
                          width: 240,
                          height: 340,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
                            borderRadius: const BorderRadius.all(Radius.elliptical(120, 170)),
                          ),
                        ),
                      ),

                      // Shutter Flash Overlay
                      if (_showShutter)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),

                      // Top Right Camera Switch Icon
                      Positioned(
                        top: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: _toggleCamera,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 22),
                          ),
                        ),
                      ),

                      // Bottom Right Upload Icon
                      Positioned(
                        bottom: 24,
                        right: 16,
                        child: GestureDetector(
                          onTap: _pickFromGallery,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppColors.editorialBackground,
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: _pickFromGallery,
                              child: const Icon(Icons.file_upload_outlined, color: AppColors.editorialTextPrimary, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Scanning Progress Bar (Conditional)
              if (_isScanning) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SCANNING PROGRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.editorialTextPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.editorialTextPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.editorialDivider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.editorialTextPrimary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              if (_isScanning)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _completeScan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.editorialTextPrimary,
                            foregroundColor: AppColors.editorialBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'CAPTURE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _stopScan,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.editorialTextPrimary, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: AppColors.editorialTextPrimary,
                          ),
                          child: const Text(
                            'STOP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
              // Main Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: AppColors.editorialBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    (_isProcessing ? 'CALCULATING...' : 'BEGIN ASSESSMENT').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Scanning Instructions
              const Text(
                'PROTOCOLS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.editorialTextPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.editorialCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInstructionItem(1, 'Ensure patient is seated in neutral position'),
                    const SizedBox(height: 16),
                    _buildInstructionItem(2, "Adequate front lighting on patient's face"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.editorialTextPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.editorialTextSecondary,
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
