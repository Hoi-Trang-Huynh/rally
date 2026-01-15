/// Model representing the upload signature response from Cloudinary.
class CloudinarySignature {
  /// The signature string.
  final String signature;

  /// The timestamp of the signature.
  final int timestamp;

  /// The API key for the Cloudinary account.
  final String apiKey;

  /// The cloud name for the Cloudinary account.
  final String cloudName;

  /// The public ID to use for the uploaded file (optional).
  final String? publicId;

  /// Creates a new [CloudinarySignature].
  const CloudinarySignature({
    required this.signature,
    required this.timestamp,
    required this.apiKey,
    required this.cloudName,
    this.publicId,
  });

  /// Creates a [CloudinarySignature] from JSON.
  factory CloudinarySignature.fromJson(Map<String, dynamic> json) {
    return CloudinarySignature(
      signature: json['signature'] as String,
      timestamp: json['timestamp'] as int,
      apiKey: json['api_key'] as String,
      cloudName: json['cloud_name'] as String,
      publicId: json['public_id'] as String?,
    );
  }
}
