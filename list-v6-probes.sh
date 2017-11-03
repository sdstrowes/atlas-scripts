#!/usr/bin/env python

import bz2
import json
import sys

def load_archive(fn):
	probes = {}
	compressed = bz2.BZ2File(fn)
	probes = json.loads(compressed.read())
	probes = probes["objects"]
	return probes

def count_asns(archive):
	v4counts  = {}
	v6counts  = {}

	v4diffcounts = {}
	v6diffcounts = {}

	for probe in archive:
		if probe["asn_v6"] is not None:
			asn = probe["asn_v6"]
			v6counts.setdefault(asn, set())
			v6counts[asn].add(probe["id"])

			print "Added v6 probe "+str(probe["id"])+ " to ASN "+str(asn)

		if probe["asn_v4"] is not None:
			asn = probe["asn_v4"]
			v4counts.setdefault(asn, set())
			v4counts[asn].add(probe["id"])

			print "Added v4 probe "+str(probe["id"])+ " to ASN "+str(asn)

		if probe["status_name"] == "Connected" and probe["asn_v6"] is not None and probe["asn_v4"] is not None and probe["asn_v4"] != probe["asn_v6"]:
			asn = probe["asn_v6"]
			v6diffcounts.setdefault(asn, set())
			v6diffcounts[asn].add(probe["id"])

			asn = probe["asn_v4"]
			v4diffcounts.setdefault(asn, set())
			v4diffcounts[asn].add(probe["id"])

	return (v6counts, v4counts, v6diffcounts, v4diffcounts)


def settostr(a):
	return ",".join(map(str, list(a)))

def main():

	verbose = False

	if len(sys.argv) <= 1:
		print "Give me a date str, %Y%m%d"
		sys.exit(1)

	fn=sys.argv[1]
	archive = load_archive(fn)

	# these are dicts, ASN -> set(probeIDs)
	(v6, v4, v6diff, v4diff) = count_asns(archive)

	for asn in v6:
		print asn, settostr(v6[asn])


if __name__ == "__main__":
	main()


