#!/usr/bin/env python3
"""Safely validate TypeTree array spans in Unity AnimationClip object data.

This is a defensive parser primitive, not a decoder for Unity animation curves.
It deliberately rejects truncated arrays, negative lengths and unsafe offsets.
"""
import struct


def checked_array_span(blob, offset, element_size, *, max_elements=10_000_000):
    if offset < 0 or offset + 4 > len(blob):
        raise ValueError("Array count outside object bounds")
    if element_size <= 0:
        raise ValueError("Element size must be positive")
    count = struct.unpack_from("<i", blob, offset)[0]
    if count < 0 or count > max_elements:
        raise ValueError(f"Invalid array element count: {count}")
    start = offset + 4
    end = start + count * element_size
    if end > len(blob):
        raise ValueError(f"Array payload exceeds object bounds: {end}/{len(blob)}")
    return count, start, end


def align4_checked(offset, limit):
    if offset < 0 or limit < 0:
        raise ValueError("Negative offset")
    aligned = (offset + 3) & ~3
    if aligned > limit:
        raise ValueError(f"Alignment exceeds object bounds: {aligned}/{limit}")
    return aligned
