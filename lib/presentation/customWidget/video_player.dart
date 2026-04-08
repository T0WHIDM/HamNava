import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAndCacheVideo();
  }

  Future<void> _initializeAndCacheVideo() async {
    try {
      final fileInfo = await DefaultCacheManager().getSingleFile(
        widget.videoUrl,
      );

      if (!mounted) return;

      _controller = VideoPlayerController.file(fileInfo)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
              _isLoading = false;
            });
          }
        });

      _controller!.addListener(() {
        if (_controller!.value.position == _controller!.value.duration) {
          setState(() {});
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(
          child: SpinKitPulse(color: Color(0xFF0ED0D3), size: 30),
        ),
      );
    }

    if (_hasError || !_isInitialized || _controller == null) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  if (_controller!.value.position ==
                      _controller!.value.duration) {
                    _controller!.seekTo(Duration.zero);
                  }
                  _controller!.play();
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
