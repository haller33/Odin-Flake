# MIT License
#
# Copyright (c) 2023 Any
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in with pkgs; {
        devShells.default = mkShell {
          LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${
              with pkgs;
              pkgs.lib.makeLibraryPath [
                libGL
                xorg.libX11
                xorg.libXi
                SDL2
                SDL
                vulkan-loader
                glfw
              ]
            }";

          buildInputs = [
            (odin.overrideAttrs (finalAttr: prevAttr: {

              src = fetchFromGitHub {
                owner = "odin-lang";
                repo = "Odin";
                rev = finalAttrs.version;
                hash = "sha256-nBq/R2BYqSpuo8H0DBE4cgkV5OxyK5zSnhzRTpAp/FQ=";
                # name = "${finalAttrs.pname}-${finalAttrs.version}"; # not gona work .
              };

              preBuild = ''

                echo "# for use of STB libraries"
                cd vendor/stb/src
                make
                cd ../../..

              '';

            }))

            # SDL
            SDL2
            SDL

            # GLFW
            glfw

            # vulkan
            vulkan-headers
            vulkan-loader
            vulkan-tools

            # x11 and raylib stuff
            glxinfo
            lld
            gnumake
            xorg.libX11.dev
            xorg.libX11
            xorg.libXft
            xorg.libXi
            xorg.libXinerama
            libGL

            ## not need because of vendor
            # stb
            # lua

            valgrind
            rr

            # needed for raylib
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXinerama
          ];
        };
      });
}
