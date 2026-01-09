{inputs, ...}: {
  _module.args.internal-lib = import ../../lib {inherit inputs;};
}
