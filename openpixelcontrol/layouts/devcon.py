#!/usr/bin/env python

size_w = 38
size_h = 24

size_w_scaled = size_w/2
size_h_scaled = size_h/2

spacing = 0.11  # m
lines = []
for posy in reversed(range(size_h)):
    range_x = [reversed(range(size_w)), range(size_w)][posy % 2]
    for posx in range_x:
        #print("posy:" + str(posy) + " posx: " + str(posx))
        x, y, z = (size_w_scaled*-spacing)+(posx*spacing), 0, (size_h_scaled*-spacing)+(posy*spacing)
        lines.append('  {"point": [%.2f, %.2f, %.2f]}' % (x, y, z))
print '[\n' + ',\n'.join(lines) + '\n]'

"""
for c in range(-size_w_scaled, size_w_scaled):
    rs = [reversed(range(size_h)), range(size_h)][c % 2]
    #print("c: " + str(c) + " rs: " + str(rs))
    for r in rs:
        x, y, z = -c*spacing, 0, (-r - size_w_scaled)*spacing
        lines.append('  {"point": [%.2f, %.2f, %.2f]}' % (x, y, z))
print '[\n' + ',\n'.join(lines) + '\n]'
"""