import AppKit

// App icon: a single glass keycap with a sparkle on a deep midnight tile. Usage: swift make-icon.swift <out.png>
let S: CGFloat = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(S), pixelsHigh: Int(S), bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                           bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
func c(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor { NSColor(red: r, green: g, blue: b, alpha: a) }
func grad(_ cols: [NSColor], _ locs: [CGFloat]? = nil) -> NSGradient { NSGradient(colors: cols, atLocations: locs, colorSpace: .deviceRGB)! }
let blue = c(0.40, 0.62, 1.0), violet = c(0.50, 0.40, 1.0)

// Tile
let tile = NSRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = NSBezierPath(roundedRect: tile, xRadius: 185, yRadius: 185)
ctx.saveGState()
let sh = NSShadow(); sh.shadowColor = c(0, 0, 0, 0.5); sh.shadowBlurRadius = 28; sh.shadowOffset = NSSize(width: 0, height: -14); sh.set()
c(0.05, 0.05, 0.1).setFill(); tilePath.fill()
ctx.restoreGState()

ctx.saveGState(); tilePath.addClip()
grad([c(0.13, 0.13, 0.24), c(0.04, 0.04, 0.09)]).draw(in: tile, angle: -90)
// ambient colour bloom behind the key
let bloom = NSGradient(colors: [c(0.42, 0.40, 1.0, 0.55), c(0.42, 0.40, 1.0, 0)])!
bloom.draw(fromCenter: NSPoint(x: 512, y: 512), radius: 0, toCenter: NSPoint(x: 512, y: 512), radius: 380, options: [])
ctx.restoreGState()
c(1, 1, 1, 0.10).setStroke()
let rim = NSBezierPath(roundedRect: tile.insetBy(dx: 1.5, dy: 1.5), xRadius: 184, yRadius: 184); rim.lineWidth = 3; rim.stroke()

// Keycap (centered)
let cap = NSRect(x: 292, y: 292, width: 440, height: 440)
let capPath = NSBezierPath(roundedRect: cap, xRadius: 118, yRadius: 118)
// key depth edge
ctx.saveGState()
let ds = NSShadow(); ds.shadowColor = c(0.45, 0.4, 1.0, 0.6); ds.shadowBlurRadius = 60; ds.shadowOffset = .zero; ds.set()
c(0.22, 0.18, 0.62).setFill()
NSBezierPath(roundedRect: cap.offsetBy(dx: 0, dy: -26), xRadius: 118, yRadius: 118).fill()
ctx.restoreGState()
ctx.saveGState()
capPath.addClip()
grad([blue, violet, c(0.36, 0.28, 0.9)], [0, 0.55, 1]).draw(in: cap, angle: -55)
grad([c(1, 1, 1, 0.38), c(1, 1, 1, 0)]).draw(in: NSRect(x: 292, y: 512, width: 440, height: 220), angle: -90)
ctx.restoreGState()
c(1, 1, 1, 0.55).setStroke()
let capRim = NSBezierPath(roundedRect: cap.insetBy(dx: 2, dy: 2), xRadius: 116, yRadius: 116); capRim.lineWidth = 4; capRim.stroke()

// Sparkle on the key
let cx: CGFloat = 512, cy: CGFloat = 512, r: CGFloat = 130, k: CGFloat = 20
let p = NSBezierPath()
p.move(to: NSPoint(x: cx, y: cy + r))
p.curve(to: NSPoint(x: cx + r, y: cy), controlPoint1: NSPoint(x: cx + k, y: cy + k), controlPoint2: NSPoint(x: cx + k, y: cy + k))
p.curve(to: NSPoint(x: cx, y: cy - r), controlPoint1: NSPoint(x: cx + k, y: cy - k), controlPoint2: NSPoint(x: cx + k, y: cy - k))
p.curve(to: NSPoint(x: cx - r, y: cy), controlPoint1: NSPoint(x: cx - k, y: cy - k), controlPoint2: NSPoint(x: cx - k, y: cy - k))
p.curve(to: NSPoint(x: cx, y: cy + r), controlPoint1: NSPoint(x: cx - k, y: cy + k), controlPoint2: NSPoint(x: cx - k, y: cy + k))
p.close()
ctx.saveGState()
let g = NSShadow(); g.shadowColor = c(0.1, 0.05, 0.5, 0.45); g.shadowBlurRadius = 24; g.shadowOffset = NSSize(width: 0, height: -8); g.set()
c(1, 1, 1).setFill(); p.fill()
ctx.restoreGState()

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
