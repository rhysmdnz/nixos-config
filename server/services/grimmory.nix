{ pkgs, ... }:

{
  services.grimmory = {
    enable = true;
    host = "0.0.0.0";
    port = 7070;
    booksDir = "/mnt/s/books";
    database = {
      name = "booklore";
      user = "booklore";
      passwordFile = "/var/lib/grimmory-secrets/db-password";
    };
  };
}
