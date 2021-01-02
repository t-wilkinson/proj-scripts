#!/usr/bin/bash
# Notes for bash scripting

while [[ $# > 0 ]]; do
    case $1 in
        -p) project=$2; shift;;
        --project=*) project=${1#*=};;
        --front|--frontend) project=frontend;;
        --back|--backend) project=backend;;
        --repl) repl=1;;
        -*)
            for (( i=1; i<${#1}; i++ )); do
                case ${1:$i:1} in
                    r) repl=1;;
                    f) project=frontend;;
                    b) project=backend;;
                    c) css=1;;
                    *) error $1; exit 1;;
                esac
            done
            ;;
        *) error $1; exit 1;;
    esac
    shift
done


OPTS=fbrcp
LONGOPTS=front,back,repl,project,css

! PARSED=$(getopt --options=$OPTS --longoptions=$LONGOPTS --name "$0" -- "$@")

[[ ${PIPESTATUS[0]} == 0 ]] || exit 2

eval set -- "$PARSED"


# if [[ ! $project =~ ^(f|b|c) ]]; then
#     echo "Must be -p must be: [f(frontend) | b(backend) | c(css)]"
#     exit 1
# fi

if [[ $css ]]; then
    cd resources
    gulp -f ~/dev/sites/js/gulpfile.js --cwd `pwd`
elif [[ $repl && $project ]]; then
    if [[ $IN_NIX_SHELL ]]; then
        cabal new-repl $project
    else
        nix-shell -A shells.ghc --run "cabal new-repl $project"
    fi
elif [[ $project ]]; then
    if [[ $IN_NIX_SHELL ]]; then
        ghcid -c "cabal new-repl $project" -T Main.main --restart $project/$project.cabal
    else
        nix-shell -A shells.ghc --run "ghcid -c cabal new-repl $project -T Main.main --restart $project/$project.cabal"
    fi
else
    echo "bad arguments"
fi


