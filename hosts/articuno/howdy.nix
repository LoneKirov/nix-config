_: {
  services = {
    howdy = {
      enable = true;
      control = "sufficient";
      settings.core.use_cnn = true;
    };
    linux-enable-ir-emitter.enable = true;
  };
  security.pam.services.greetd.howdy.control = "sufficient";
}
