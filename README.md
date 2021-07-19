# write-test-container

## image

Used for examining the permissions of container mounts. Shows the
extended attributes of the /mnt dir, tries to write to it, and then
shows the extended attributes of the created file.

## k8s

Resources to run the image in multiple scenarios. Will create a BuildConfig
and ImageStream to build the image.

To use it successfully, you'll need to change the fsGroup in the fsgroupproject.yaml
files to match the annotation on your namespace. It should be the first value of the
`openshift.io/sa.scc.supplemental-groups` from your namespace.

You can adjust the kustomize to match with:

```sh
find -name "fsgroupproject.yaml" | xargs sed -i "s/1000670000/<your fsGroup>/"
```

Then apply to your cluster (make sure you are in the right namespace):

```sh
oc apply -k k8s/overlays/all
```

## report.sh

Bash script to iterate over the Jobs in the namespace and report on them.

Will only work if the tests are the _only_ jobs in the namespace. You also
need to be logged into your cluster and be in the right namespace.