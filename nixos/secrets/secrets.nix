let
  ChristopherCrutchfield = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2Z7LbaDPTNkdnuvFivXTUx8X9gU0ZyWrrYBH7KSmG3";
  SeanPerry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILwsfYNsl6DSg00wOjvTip7GwO+aANfEBn6T3YcAHNG";
  TomZhang = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXgqrmbaafQ4GAqSVMXFoPsOYeVGUtXDGGY9AfkgCoQ";
  users = [ ChristopherCrutchfield SeanPerry TomZhang ];

in
{
  "secret1.age".publicKeys = [ ChristopherCrutchfield SeanPerry TomZhang ];
}

