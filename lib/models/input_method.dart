enum InputMethod {
  camera('Camera'),
  gallery('Image Upload'),
  text('Text Input'),
  voice('Voice Input');

  const InputMethod(this.label);
  final String label;
}
