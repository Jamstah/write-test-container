#!/bin/sh

echo "| Job | Job spec fsGroup | Pod Admitted | Effective SCC | Pod spec fsGroup | UID | GID | Groups | Volume UID | Volume GID | Volume perms | Writable | Written UID | Written GID | Written perms |"
echo "| === | ================ | ============ | ============= | ================ | === | === | ====== | ========== | ========== | ============ | ======== | =========== | =========== | ============= |"

while read JOB_NAME JOB_UID JOB_FSGROUP; do
  unset POD_NAME POD_SCC POD_FSGROUP POD_PHASE
  unset CONTAINER_UID CONTAINER_GID CONTAINER_GROUPS
  unset VOLUME_PERMS VOLUME_LINKS VOLUME_OWNER VOLUME_GROUP VOLUME_LABELS
  unset CONTAINER_FILE_PERMS CONTAINER_FILE_LINKS CONTAINER_FILE_OWNER CONTAINER_FILE_GROUP CONTAINER_FILE_LABELS

  read POD_NAME POD_SCC POD_PHASE POD_FSGROUP < <(oc get pod -l controller-uid=$JOB_UID -o json | jq -r '.items[0] | [ .metadata.name, .metadata.annotations["openshift.io/scc"], .status.phase, .spec.securityContext.fsGroup ] | @tsv')
  if [ ! -z "$POD_NAME" ]; then
    {
      read CONTAINER_UID CONTAINER_GID CONTAINER_GROUPS
      read VOLUME_PERMS VOLUME_LINKS VOLUME_OWNER VOLUME_GROUP VOLUME_LABELS SCRATCH
      read CONTAINER_FILE_PERMS CONTAINER_FILE_LINKS CONTAINER_FILE_OWNER CONTAINER_FILE_GROUP CONTAINER_FILE_LABELS
    } < <(oc logs "$POD_NAME")
  fi

  echo -n "| $JOB_NAME | $JOB_FSGROUP "
  if [ ! -z "$POD_NAME" ]; then
    echo -n "| Yes | $POD_SCC | $POD_FSGROUP "
    echo -n "| $CONTAINER_UID | $CONTAINER_GID | $CONTAINER_GROUPS "
    echo -n "| $VOLUME_OWNER | $VOLUME_GROUP | $VOLUME_PERMS "
    if [ "touch:" != "$CONTAINER_FILE_PERMS" ]; then
      echo -n "| Yes | $CONTAINER_FILE_OWNER | $CONTAINER_FILE_GROUP | $CONTAINER_FILE_PERMS "
    else
      echo -n "| No "
    fi
  else
    echo -n "| No "
  fi
  echo "|"
done < <(oc get job -o json | jq -r '.items[] | [ .metadata.name, .spec.template.metadata.labels["controller-uid"], .spec.template.spec.securityContext.fsGroup ] | @tsv')