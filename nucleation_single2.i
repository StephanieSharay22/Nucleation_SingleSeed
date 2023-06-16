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
  nx = 200 # number of elements in x direction
  ny = 200 # number of elements in y direction
  xmin = -50
  xmax = 50 # upper x coordinate of generated mesh
  ymin = -50
  ymax = 50 # upper y coordinate of generated mesh
  elem_type = QUAD
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
    variable = eta
    invalue = 1
    outvalue = 0
    radius = 5
    int_width = 1.414
    x1 = 0
    y1 = 0
  [../]
[]

[Kernels]
  [./detadt] # time derivative deta/dt
    type = ADTimeDerivative
    variable = eta
  [../]

  [./ACBulk]
    type = ADAllenCahn
    variable = eta
    f_name = F
    mob_name = L
  [../]

  [./ACInterface]
    type = ADACInterface
    variable = eta
    kappa_name = kappa
    variable_L = false
  [../]
[]


[Materials]
  [./consts]
    type = ADGenericConstantMaterial
    prop_names  = 'L deltaF   W kappa'
    prop_values = '1 0.4714  1 1'
  [../]

# ParsedMaterial method
  [./free_energy]
    type = ADDerivativeParsedMaterial
    args  = 'eta'
    f_name = p
    material_property_names = 'deltaF'
    function ='deltaF*eta^3*(10-15*eta+6*eta^2)'
  [../]
  [./barrierF]
    type = ADDerivativeParsedMaterial
    args = 'eta'
    f_name = g
    material_property_names = 'W'
    function = 'W * eta^2 * (1 - eta)^2'
  [../]
  [./bulkF]
    type = ADDerivativeParsedMaterial
    args = 'eta'
    f_name = F
    material_property_names = 'g p'
    function = 'g - p'
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
[]


[Executioner]
  type = Transient
  scheme = 'bdf2'
  solve_type = 'NEWTON'
  end_time = 200
  dt = 1
[]

[Outputs]
  exodus = true
  csv = true
[]
