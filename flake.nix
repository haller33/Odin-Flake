# MIT License
#
# Copyright (c) 2023 haller33 and znaniye
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
      let pkgs = import nixpkgs { inherit system; }; # import ./shell.nix { inherit pkgs; }; # import nixpkgs { inherit system; };
      in with pkgs; {
        devShells.default = mkShell {
          LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${
              with pkgs;
              pkgs.lib.makeLibraryPath [
                # for raylib and openGL
                pkgs.libGL
                pkgs.xorg.libX11
                pkgs.xorg.libXi

                # for SDL and SDL2
                pkgs.SDL2
                pkgs.SDL2_mixer
                pkgs.SDL

                # for vulkan and GLFW
                pkgs.vulkan-loader
                pkgs.glfw
              ]
            }";

          buildInputs = [
            (odin.overrideAttrs (finalAttr: prevAttr: {

              src = fetchFromGitHub {
                owner = "odin-lang";
                repo = "Odin";
                rev = "dev-2023-11"; # version of the branch
                hash = "sha256-5plcr+j9aFSaLfLQXbG4WD1GH6rE7D3uhlUbPaDEYf8=";
                # name = "${finalAttr.pname}-${finalAttr.version}"; # not gona work .
              };

              preBuild = ''

                echo "# for use of STB libraries"
                cd vendor/stb/src
                make
                cd ../../..

              '';

            }))

            # SDL
            pkgs.SDL2
            pkgs.SDL2_mixer
            pkgs.SDL

            # GLFW
            pkgs.glfw

            # vulkan
            pkgs.vulkan-headers
            pkgs.vulkan-loader
            pkgs.vulkan-tools

            # x11 and raylib stuff
            pkgs.glxinfo
            pkgs.lld
            pkgs.gnumake
            pkgs.xorg.libX11.dev
            pkgs.xorg.libX11
            pkgs.xorg.libXft
            pkgs.xorg.libXi
            pkgs.xorg.libXinerama
            pkgs.libGL

            ## not need because of vendor
            # stb
            # lua

            # debugging stuff and profile
            pkgs.valgrind
            pkgs.rr
            pkgs.gdb
            pkgs.lldb
            pkgs.gf

            # Graphics Debugger
            pkgs.renderdoc


            # needed for raylib
            pkgs.xorg.libXcursor
            pkgs.xorg.libXrandr
            pkgs.xorg.libXinerama
          ];
        };
      });
}
