{ pkgs }:
let
  kbclient = pkgs.fetchFromGitHub {
    owner = "kubernetes-client";
    repo = "haskell";
    rev = "47d88d7061cda5227c8f7819e3a640c7dea247f3";
    hash = "sha256-31KF3jj4WRyJwO76PPQjalnNGF0mIU2MRAe4Y2V1kU8=";
  };
in
{
  plutarch = {
    "1.4.0" = {
      timestamp = "2024-01-16T11:00:00Z";
      src = pkgs.fetchFromGitHub {
        owner = "plutonomicon";
        repo = "plutarch-plutus";
        rev = "8d6ca9e5ec8425c2f52faf59a4737b4fd96fb01b";
        hash = "sha256-dMdJxXiBJV7XSInGeSR90/sTWHTxBm3DLaCzpN1SER0=";
      };
    };
  };
  plutarch-orphanage = {
    "1.0.3" = {
      timestamp = "2024-07-29T00:00:00Z";
      subdir = "plutarch-orphanage";
      src = pkgs.fetchFromGitHub {
        owner = "plutonomicon";
        repo = "plutarch-plutus";
        rev = "e50661e24670974b398be19426617bc6389fdac6";
        hash = "sha256-BcqNHF4LCHwGs+Q+nPKNDOAPZwPvBhKDb7f3s/kkFho=";
      };
    };
  };
  kubernetes-client = {
    "0.5.0.0" = {
      subdir = "kubernetes-client";
      src = kbclient;
    };
  };
}
