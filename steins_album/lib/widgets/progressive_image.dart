import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../services/image_cache_service.dart';

class ProgressiveImage extends StatelessWidget {
  final AssetEntity asset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableFullResolution;

  const ProgressiveImage({
    Key? key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.enableFullResolution = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageCacheService>(
      builder: (context, cacheService, child) {
        return FutureBuilder<File?>(
          future: cacheService.getCachedImage(
            asset,
            thumbnail: !enableFullResolution,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SizedBox(
                width: width,
                height: height,
                child: errorWidget ?? const Icon(Icons.error),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return SizedBox(
                width: width,
                height: height,
                child: placeholder ?? const CircularProgressIndicator(),
              );
            }

            return Image.file(
              snapshot.data!,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  width: width,
                  height: height,
                  child: errorWidget ?? const Icon(Icons.error),
                );
              },
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: frame != null
                      ? child
                      : SizedBox(
                          width: width,
                          height: height,
                          child: placeholder ?? const CircularProgressIndicator(),
                        ),
                );
              },
            );
          },
        );
      },
    );
  }
} 