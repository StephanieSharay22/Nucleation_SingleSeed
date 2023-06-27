#
# Test the DiscreteNucleation material in a toy system. The global
# concentration is above the solubility limit, but below the spinodal.
# Without further intervention no nucleation will occur in a phase
# field model. The DiscreteNucleation material will locally modify the
# free energy to coerce nuclei to grow.
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50 # number of elements in x direction
  ny = 50 # number of elements in y direction
  xmin = -50
  xmax = 50 # upper x coordinate of generated mesh
  ymin = -50
  ymax = 50 # upper y coordinate of generated mesh
  elem_type = QUAD
[]

[Adaptivity]
  steps = 1
  marker = eta_mark
  max_h_level = 2
  initial_steps = 2
  initial_marker = uniform
  [Markers]
    [eta_mark]
      type = ValueRangeMarker
      variable = eta
      lower_bound = 0.1
      upper_bound = 0.9
    []
    [uniform]
      type = UniformMarker
      mark = REFINE
    []
  []
[]


[Variables]
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]

[]


[ICs]
  [./eta_IC]
    type = SmoothCircleIC
    profile = TANH
    variable = eta
    invalue = 1
    outvalue = 0
    radius = 5
    int_width = 3.1113
    x1 = 0
    y1 = 0
  [../]
[]

[Kernels]
  [./detadt] # time derivative deta/dt
    type = TimeDerivative
    variable = eta
  [../]

  [./ACBulk]
    type = AllenCahn
    variable = eta
    f_name = F
    mob_name = L
  [../]

  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa
    variable_L = false
  [../]
[]


[Materials]
  [./consts]
    type = GenericConstantMaterial
    prop_names  = 'L deltaF   W kappa'
    prop_values = '1 0.04714  1 1'
  [../]

# ParsedMaterial method
  [./free_energy]
    type = DerivativeParsedMaterial
    args  = 'eta'
    f_name = p
    material_property_names = 'deltaF'
    function ='deltaF*eta^3*(10-15*eta+6*eta^2)'
  [../]
  [./barrierF]
    type = DerivativeParsedMaterial
    args = 'eta'
    f_name = g
    material_property_names = 'W'
    function = 'W * eta^2 * (1 - eta)^2'
  [../]
  [./bulkF]
    type = DerivativeParsedMaterial
    args = 'eta'
    f_name = F
    material_property_names = 'g(eta) p(eta)'
    function = 'g(eta) - p(eta)'
    outputs = exodus
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = F
  [../]
  [radius]
    type = FindValueOnLine
    v = eta
    target = 0.5
    tol = 0.01
    start_point = '0 0 0'
    end_point = '0 50 0'
    error_if_not_found = false
  []
[]


[Executioner]
  type = Transient
  scheme = 'bdf2'
  solve_type = 'NEWTON'
  end_time = 200
  dt = 0.5
[]

[Outputs]
  exodus = true
  csv = true
[]
