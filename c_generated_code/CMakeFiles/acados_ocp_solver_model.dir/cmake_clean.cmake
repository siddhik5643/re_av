file(REMOVE_RECURSE
  "acados_ocp_solver_model.dll"
  "acados_ocp_solver_model.dll.manifest"
  "acados_ocp_solver_model.lib"
  "acados_ocp_solver_model.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang C)
  include(CMakeFiles/acados_ocp_solver_model.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
