#' Tools for hydrogeology and poroelasticity.
#' 
#' This package provides tools to calculate quantities
#' commonly found in hydrogeology and poroelasticity studies including,
#' to name a few, hydraultic conductivity, permeability, transmissivity, etc.
#' 
#' @section Scientific background:
#' 
#' TODO
#'
#' \subsection{Physical parameters}{
#' TODO
#' }
#'
#' @docType package
#' @name hydrogeo.p-package
#' @aliases hydrogeo.p
#' @author Andrew J. Barbour <andy.barbour@@gmail.com> 
#' 
#' @importFrom utils data str
#' @importFrom grDevices dev.cur grey
#' @importFrom graphics lines par plot polygon rect segments text
#' @importFrom reshape2 dcast
#' 
#' @references Brocher, T. M. (2005). 
#' Empirical relations between elastic wavespeeds and density in the Earth's crust. 
#' \emph{Bulletin of the Seismological Society of America}, \strong{95} (6), 2081-2092.
#' 
#' @references Davies, S. N., and R. J. M. DeWiest (1966), 
#' \strong{Hydrogeology}, \emph{J Wiley and Sons}, \emph{New York}, 61.
#'
#' @references Lachenbruch, A. H. (1980),
#' Frictional heating, fluid pressure, and the resistance to fault motion,
#' \emph{J. Geophys. Res.}, \strong{85} (B11), 6097-6112,
#' doi: 10.1029/JB085iB11p06097
#' 
#' @references Rice, J. R., and M. P. Cleary (1976),
#' Some basic stress diffusion solutions for fluid-saturated elastic porous 
#' media with compressible constituents,
#' \emph{Rev. Geophys.}, \strong{14} (2), 227-241, 
#' doi:10.1029/RG014i002p00227
#' 
#' @references Roeloffs, E. (1996),
#' Poroelastic Techniques in the Study of Earthquake-Related Hydrologic Phenomena,
#' \emph{Advances in Geophysics}, \strong{37}, 135-195,
#' doi: 10.1016/S0065-2687(08)60270-8
#' 
#' @references Rojstaczer, S., and D.C. Agnew (1989), 
#' The Influence of Formation Material Properties on the Response of 
#' Water Levels in Wells to Earth Tides and Atmospheric Loading,
#' \emph{J. Geophys. Res.}, \strong{94} (B9), 12403-12411.
#' 
#' @references Shapiro, S. A., Huenges, E. and Borm, G. (1997), 
#' Estimating the crust permeability from fluid-injection-induced 
#' seismic emission at the KTB site,
#' \emph{Geophysical Journal International}, \strong{131} (2),
#' doi: 10.1111/j.1365-246X.1997.tb01215.x
#' 
#' @references Shepard, F. P. (1954),
#' Nomenclature based on sand-silt-clay ratios,
#' \emph{Journal of Sedimentary Research}, \strong{24} (3), 151-158.
#' 
#' @seealso 
#' \code{\link{compressibility}},
#' \code{\link{dimensional_units}},
#' \code{\link{hydrogeo.p-constants}},
#' \code{\link{hydrogeo.p-units}},
#' \code{\link{hydraulic_diffusivity}}, 
#' \code{\link{hydraulic_conductivity}},
#' \code{\link{permeability}},
#' \code{\link{porosity}},
#' \code{\link{skempton}},
#' \code{\link{storativity}},
#' \code{\link{transmissivity}}
#'  
NULL

#
# Datasets
#

#' Constants used as defaults
#' 
#' The hydrogeologic response of an aquifer system depends on its mechanical
#' and hydraulic properties; if these are not known or 
#' specified, these constants are used.
#' 
#' @details The helper function \code{\link{constants._hg_}}
#' shows (the structure of, optionally)
#' and returns \code{.hg_constants}. 
#' \code{\link{get_constants}} simply accesses \code{\link{constants._hg_}}
#'
#' The following constants are set here:
#' gravity, properties of water, Poisson's ratios for a typical
#' drained and undrained material, the compressibities
#' of fluid and undrained fluid-saturated rock,
#' atmospheric properties at ATP, and some conversion
#' factors.
#' 
#' @note This functionality may be replaced in the future with
#' the \code{\link[settings]{options_manager}} function on CRAN
#' (in the  new \pkg{settings} package).
#' 
#' @name hydrogeo.p-constants
#' @export
#' @seealso \code{\link{hydrogeo.p-units}}, \code{\link{hydrogeo.p}}
.hg_constants <- list(gravity=list(
                     std=9.80665 # 6371 km
                   ),
                   water=list(
                     dens=1000, #  kg/m^3
                     dyn_visc=1.002e-3 # Pa*s at 20 degC
                   ),
                   Poisson=list(
                     nu=0.25,      #for a Poisson solid
                     nu_u=1/3,
                     VpVs=sqrt(3) #for a Poisson solid
                   ),
                   compressibility=list(
                     Beta_u=2e-11,   # a very rigid matrix,
                     Beta_f=4.4e-10 # a rigid matrix
                   ),
                   atm=list(
                     bar=1.013250, # std atm in bars
                     m_per=10.3, # meters of water per atmosphere
                     L.=0.0065, # temperature lapse rate  K/m
                     To.=288.15, # sea level standard temperature  K
                     M.=0.0289644, # molar mass of dry air  kg/mol
                     R.=8.31447 # universal gas constant  J/(mol*K)
                   ),
                   conversions=list(
                     sqm2sqcm=1e4 # m^2 --> cm^2
                   )
)

#' @rdname hydrogeo.p-constants
#' @param do.str logical; should the structure be printed?
#' @export
#' @aliases constants
# @example
# constants._hg_()
constants._hg_ <- function(do.str=TRUE){
  const <- hydrogeo.p::.hg_constants
  if (do.str) str(const, comp.str = "++++++++\n\t", no.list=TRUE, digits.d = 9)
  return(invisible(const))
}
#' @rdname hydrogeo.p-constants
#' @export
get_constants <- function(){
  hydrogeo.p::constants._hg_(do.str=FALSE)
}

#' Ranges of diffusivity for a few types of solid-rock and unconsolidated deposits.
#'
#' In general, hydraulic diffusivities can vary over many orders of magnitude, and
#' laboratory- and field-based estimates often disagree significantly.  This 
#' dataset represents a (limited) compilation
#' of any available sources (including other compilations!), and is meant to 
#' show the range of 'typical' values, expressed in SI units: \eqn{[m^2/s]}. I also
#' include values estimated for fault-core material.
#' 
#' \itemize{
#'   \item mat.type   Type of material
#'   \item mat.class  Class
#'   \item mat.state  State
#'   \item d.high     Upper bound on typical values of diffusivity \eqn{[m^2/s]}
#'   \item d.low      Lower bound
#'   \item ref        Reference
#' }
#'
#' The value of \code{ref} gives the source which the diffusivity range is from.
#' Current sources include:
#' \itemize{
#'   \item Do06        Doan et al 2006 (Chelungpu fault, Taiwan)
#'   \item Ro96        Roeloffs 1996 (shown in Ref. fig. 14)
#'   \item Wa00        Wang 2000 (App. C.1)
#'   \item Wi00        Wibberley 2002 (MTL, Japan)
#' }
#'
#' @docType  data
#' @keywords  datasets
#' @name  diffusiv
#' @usage  data(diffusiv)
# @format  A data frame with 19 rows and 6 variables
NULL

#' Shepard's (1954) grain-size classification.
#' 
#' Values are percent grain-size due to sand, silt, and clay in
#' sedimentary material.
#' 
#' For use in ternary plots.
#' 
#' @seealso \code{\link{sand_silt_clay}} and \code{\link{shepard_plot}}
#' @references Shepard, F.P. (1954),
#' Nomenclature based on sand-silt-clay ratios,
#' \emph{Journal of Sedimentary Petrology}, \strong{24}, p. 151-158.
#' @docType  data
#' @keywords  datasets
#' @name  shepard
#' @usage  data(shepard)
# @format  A data frame with 18 rows and 4 variables
NULL
