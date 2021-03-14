function deploy_doc(){
    if [ ! -z "$1" ]
    then
        git checkout $1
    fi
    COMMIT=$(git rev-parse --short HEAD)
    echo "Creating doc at commit" $COMMIT "and pushing to folder $2"
    pip install -U ..
    if [ ! -z "$2" ]
    then
        if [ "$2" == "latest" ]; then
            echo "Pushing master"
            sphinx-build source _build -a && mkdir build && mkdir build/$2 && cp -a _build/* build/$2/
        elif ssh -oStrictHostKeyChecking=no $doc "[ -d build/$2 ]"; then
            echo "Directory" $2 "already exists"
        else
            echo "Pushing version" $2
            cp -r _static source/
            sphinx-build source _build -a
            mkdir build/$2 && cp -a _build/* build/$2/
        fi
    else
        echo "Pushing stable"
        cp -r _static source/
        sphinx-build source build -a
    fi
}

# You can find the commit for each tag on https://github.com/frgfm/torch-cam/tags
if [ -d build ]; then rm -Rf build; fi
cp -r source/_static .
deploy_doc "" latest
deploy_doc "7be0b4f" v0.1.0
deploy_doc "a95d680" v0.1.1
deploy_doc "521b4f9" # v0.1.2 Latest stable release
rm -rf _build _static
