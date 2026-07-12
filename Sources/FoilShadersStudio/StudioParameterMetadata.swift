import Foundation

struct StudioParameterMetadata {
  let range: ClosedRange<Float>?
  let options: [String]

  static func metadata(
    shader: StudioShader,
    parameter: String,
    currentValue: Float? = nil
  ) -> StudioParameterMetadata {
    let key = "\(shader.rawValue).\(parameter)"
    if let options = enumOptions[key] {
      return StudioParameterMetadata(range: nil, options: options)
    }
    if let range = documentedRanges[key] {
      return StudioParameterMetadata(range: range, options: [])
    }
    let value = currentValue ?? 0
    return StudioParameterMetadata(
      range: fallbackRange(parameter: parameter, value: value),
      options: []
    )
  }

  private static let enumOptions: [String: [String]] = [
    "dotGrid.shape": ["circle", "diamond", "square", "triangle"],
    "dithering.shape": ["simplex", "warp", "dots", "wave", "ripple", "swirl", "sphere"],
    "dithering.type": ["random", "2x2", "4x4", "8x8"],
    "warp.shape": ["checks", "stripes", "edge"],
    "grainGradient.shape": ["wave", "dots", "truchet", "corners", "ripple", "blob", "sphere"],
    "pulsingBorder.aspectRatio": ["auto", "square"],
    "imageDithering.type": ["random", "2x2", "4x4", "8x8"],
    "halftoneDots.grid": ["square", "hex"],
    "halftoneDots.type": ["classic", "gooey", "holes", "soft"],
    "halftoneCMYK.type": ["dots", "ink", "sharp"],
    "liquidMetal.shape": ["none", "circle", "daisy", "diamond", "metaballs"],
    "flutedGlass.distortionShape": ["prism", "lens", "contour", "cascade", "flat"],
    "flutedGlass.shape": ["lines", "linesIrregular", "wave", "zigzag", "pattern"],
    "gemSmoke.shape": ["none", "circle", "daisy", "diamond", "metaballs"],
  ]

  private static let documentedRanges: [String: ClosedRange<Float>] = {
    var result: [String: ClosedRange<Float>] = [:]
    let rows = documentedRangeRows.split(separator: "\n")
    for row in rows {
      let parts = row.split(separator: "|", omittingEmptySubsequences: false)
      guard parts.count == 3, let lower = Float(parts[1]), let upper = Float(parts[2]) else {
        continue
      }
      let padding = lower == upper ? max(1, abs(lower) * 0.5) : 0
      result[String(parts[0])] = (lower - padding)...(upper + padding)
    }
    return result
  }()

  private static let documentedRangeRows = """
    animatedMeshGradient.distortion|0.8|1
    animatedMeshGradient.swirl|0.1|1
    animatedMeshGradient.grainMixer|0|1
    animatedMeshGradient.grainOverlay|0|1
    smokeRing.noiseScale|1.1|3
    smokeRing.thickness|0.01|0.8
    smokeRing.radius|0.25|0.5
    smokeRing.innerShape|0.7|4
    smokeRing.noiseIterations|2|10
    neuroNoise.brightness|0|0.24
    neuroNoise.contrast|0.12|1
    dotOrbit.stepsPerColor|2|4
    dotOrbit.size|0.3|1
    dotOrbit.sizeRange|0|0.7
    dotOrbit.spreading|0.3|1
    dotGrid.dotSize|2|9
    dotGrid.gapX|20|32
    dotGrid.gapY|32|90
    dotGrid.strokeWidth|0|1
    dotGrid.sizeRange|0|1
    dotGrid.opacityRange|0|0.6
    simplexNoise.stepsPerColor|1|2
    simplexNoise.softness|0|1
    metaballs.count|7|18
    metaballs.size|0.1|0.83
    metaballs.sizeRange|0|1
    waves.shape|0|3
    waves.frequency|0.2|0.5
    waves.amplitude|0.25|1
    waves.spacing|1.05|1.25
    waves.proportion|0.1|1
    waves.softness|0|1
    perlinNoise.proportion|0.35|0.65
    perlinNoise.softness|0|0.35
    perlinNoise.octaveCount|1|8
    perlinNoise.persistence|0.55|1
    perlinNoise.lacunarity|1.5|2.55
    voronoi.stepsPerColor|1|3
    voronoi.distortion|0.38|0.5
    voronoi.gap|0|0.04
    voronoi.glow|0|1
    warp.proportion|0.05|0.67
    warp.softness|0|1.5
    warp.shapeScale|0.1|1
    warp.distortion|0|0.25
    warp.swirl|0.2|0.9
    warp.swirlIterations|3|10
    godRays.density|0.03|0.45
    godRays.spotty|0.15|0.77
    godRays.midSize|0.1|0.33
    godRays.midIntensity|0.4|0.75
    godRays.intensity|0.6|0.8
    godRays.bloom|0.4|1
    spiral.density|0.2|1
    spiral.distortion|0|1
    spiral.strokeWidth|0.5|0.75
    spiral.strokeTaper|0|0.18
    spiral.strokeCap|0|1
    spiral.noise|0|1
    spiral.noiseFrequency|0|0.33
    spiral.softness|0|0.5
    swirl.bandCount|2|5
    swirl.twist|0.1|0.3
    swirl.center|0|0.2
    swirl.proportion|0|0.5
    swirl.softness|0|1
    swirl.noise|0|0.2
    swirl.noiseFrequency|0|0.5
    dithering.size|2|11
    grainGradient.softness|0|1
    grainGradient.intensity|0.15|1
    grainGradient.noise|0.25|1
    pulsingBorder.roundness|0|1
    pulsingBorder.thickness|0|1
    pulsingBorder.marginLeft|0|1
    pulsingBorder.marginRight|0|1
    pulsingBorder.marginTop|0|1
    pulsingBorder.marginBottom|0|1
    pulsingBorder.softness|0|1
    pulsingBorder.intensity|0|0.2
    pulsingBorder.bloom|0.15|0.45
    pulsingBorder.spots|3|5
    pulsingBorder.spotSize|0.25|1
    pulsingBorder.pulse|0|0.5
    pulsingBorder.smoke|0|1
    pulsingBorder.smokeSize|0|0.6
    colorPanels.density|1.6|3
    colorPanels.angle1|-1|0.4
    colorPanels.angle2|-1|0.4
    colorPanels.length|0.52|3
    colorPanels.edges|0|1
    colorPanels.blur|0|0.5
    colorPanels.fadeIn|0|1
    colorPanels.fadeOut|0.3|1
    colorPanels.gradient|0|0.78
    staticMeshGradient.positions|0|42
    staticMeshGradient.waveX|0.45|1
    staticMeshGradient.waveXShift|0|0.7
    staticMeshGradient.waveY|0.7|1
    staticMeshGradient.waveYShift|0|0.7
    staticMeshGradient.mixing|0|0.93
    staticMeshGradient.grainMixer|0|0.37
    staticMeshGradient.grainOverlay|0|0.78
    staticRadialGradient.radius|0.8|1
    staticRadialGradient.focalDistance|0|0.99
    staticRadialGradient.focalAngle|-180|180
    staticRadialGradient.falloff|0|0.9
    staticRadialGradient.mixing|0|1
    staticRadialGradient.distortion|0|1
    staticRadialGradient.distortionShift|-1|1
    staticRadialGradient.distortionFreq|1|24
    staticRadialGradient.grainMixer|0|1
    staticRadialGradient.grainOverlay|0|0.5
    paperTexture.contrast|0|0.85
    paperTexture.roughness|0|1
    paperTexture.fiber|0.1|0.35
    paperTexture.fiberSize|0.14|0.22
    paperTexture.crumples|0|1
    paperTexture.foldCount|1|15
    paperTexture.folds|0|1
    paperTexture.fade|0|1
    paperTexture.crumpleSize|0.1|0.5
    paperTexture.drops|0|0.2
    paperTexture.seed|1.6|6
    flutedGlass.shadows|0|0.4
    flutedGlass.size|0.4|0.9
    flutedGlass.angle|0|30
    flutedGlass.distortion|0.5|1
    flutedGlass.shift|-1|1
    flutedGlass.blur|0|1
    flutedGlass.edges|0.25|0.5
    flutedGlass.marginLeft|0|0.1
    flutedGlass.marginRight|0|0.1
    flutedGlass.marginTop|0|0.1
    flutedGlass.marginBottom|0|0.1
    flutedGlass.stretch|0|1
    flutedGlass.highlights|0|0.1
    flutedGlass.grainMixer|0|0.1
    flutedGlass.grainOverlay|0|0.1
    water.highlights|0|0.4
    water.layering|0|0.5
    water.edges|0|1
    water.caustic|0|0.4
    water.waves|0|1
    water.size|0.15|1
    imageDithering.size|1|3
    imageDithering.colorSteps|1|5
    heatmap.contour|0|1
    heatmap.angle|-180|180
    heatmap.noise|0|0.75
    heatmap.innerGlow|0|1
    heatmap.outerGlow|0|1
    liquidMetal.repetition|1.5|6
    liquidMetal.softness|0.05|0.8
    liquidMetal.shiftRed|0|1
    liquidMetal.shiftBlue|-1|0.3
    liquidMetal.distortion|0|0.4
    liquidMetal.contour|0|0.4
    liquidMetal.angle|0|90
    halftoneDots.size|0.5|0.8
    halftoneDots.radius|1|2
    halftoneDots.contrast|0.01|1
    halftoneDots.grainMixer|0|0.2
    halftoneDots.grainOverlay|0|0.3
    halftoneDots.grainSize|0|1
    halftoneCMYK.size|0.01|0.88
    halftoneCMYK.contrast|1|2
    halftoneCMYK.softness|0|1
    halftoneCMYK.grainSize|0|0.5
    halftoneCMYK.grainMixer|0|0.15
    halftoneCMYK.grainOverlay|0|0.25
    halftoneCMYK.gridNoise|0.2|0.6
    halftoneCMYK.floodC|0|0.15
    halftoneCMYK.floodM|-1|1
    halftoneCMYK.floodY|-1|1
    halftoneCMYK.floodK|0|0.1
    halftoneCMYK.gainC|-0.17|1
    halftoneCMYK.gainM|-0.45|0.44
    halftoneCMYK.gainY|-1|0.2
    halftoneCMYK.gainK|-1|1
    gemSmoke.innerDistortion|0.6|1
    gemSmoke.outerDistortion|0.6|1
    gemSmoke.outerGlow|0|1
    gemSmoke.innerGlow|0.65|1
    gemSmoke.offset|0|0.2
    gemSmoke.angle|-180|180
    gemSmoke.size|0.8|1
    """

  private static func fallbackRange(parameter: String, value: Float) -> ClosedRange<Float> {
    if parameter.localizedCaseInsensitiveContains("angle") { return -180...180 }
    if parameter.localizedCaseInsensitiveContains("count") { return 0...max(20, value * 2) }
    if parameter.localizedCaseInsensitiveContains("size") { return 0...max(2, value * 2) }
    return min(0, value)...max(1, value * 2)
  }
}
