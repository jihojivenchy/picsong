enum DeepLinkType {
  none(linkName: ''),
  qr(linkName: 'qr'); // QR

  final String linkName;

  const DeepLinkType({
    required this.linkName,
  });

  factory DeepLinkType.fromLinkName(String? linkName) {
    if (linkName == null) {
      return DeepLinkType.none;
    }

    return DeepLinkType.values.firstWhere(
      (type) => type.linkName == linkName,
      orElse: () => DeepLinkType.none,
    );
  }
}
