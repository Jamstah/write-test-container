FROM registry.access.redhat.com/ubi8/ubi-minimal

CMD ["/bin/sh", "-ec", "id; ls -ldZ /mnt; touch /mnt/a; ls -lZ /mnt/a"]

USER 1001:1001
