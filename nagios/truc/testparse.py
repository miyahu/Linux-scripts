#!/usr/bin/python
# -*- coding: utf-8 -*-
# Python 3
 
import sys
 
#############################################################################
def apropos():
    print("à propos du logiciel")
 
#############################################################################
def version():
    print("version du logiciel! 1.0.0")
 
#############################################################################
def main():
    global dargs
    print(dargs['fichier'])
    print(dargs['encod'])
 
#############################################################################
if __name__ == "__main__":
 
    import argparse
 
    # création du parse des arguments
    parser = argparse.ArgumentParser(description="Editeur")
 
    # déclaration et configuration des arguments
    parser.add_argument('fichier', nargs='?', type=str, action="store", default="", help="fichier à ouvrir")
    parser.add_argument('-e', '--encod', type=str, default="", help="encodage du fichier")
    parser.add_argument('-a', '--about', action='store_true', default=False, help="A propos du logiciel")
    parser.add_argument('-v', '--version', action='store_true', default=False, help="Version du logiciel")
 
    # dictionnaire des arguments
    dargs = vars(parser.parse_args())
 
    # print(dargs) # affichage du dictionnaire pour mise au point
 
    if dargs['about']:
        apropos()
        sys.exit()
 
    if dargs['version']:
        version()
        sys.exit()
 
    main()
