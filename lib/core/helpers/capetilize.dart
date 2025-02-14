String capetilize(String input) {
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

void main() {
  String example = "hello world, this is a test.";
  print(capetilize(example)); // Outputs: "Hello World, This Is A Test."
}
