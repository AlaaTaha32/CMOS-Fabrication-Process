# 2D CMOS inverter (130 nm technology)
# ------------------------------
math coord.ucs
# Declare initial grid
# -------------------------------------

line x location= 0.0 spacing= 3.0<nm>  tag= SiTop        
line x location= 50.0<nm> spacing= 20.0<nm>                    
line x location= 0.5<um> spacing= 50.0<nm>                      
line x location= 1<um> spacing= 0.25<um>                       
line x location= 3.5<um> spacing= 0.5<um>  tag= SiBottom   

line y location= 0.0 spacing= 0.25<um> tag= Left         
line y location= 8<um> spacing= 0.25<um>  tag= Right 

# Silicon substrate definition
# ----------------------------

region Silicon xlo= SiTop xhi= SiBottom ylo= Left yhi= Right

# Initialize the simulation, wafer concentration
# --------------------------------------------

init concentration= 6.0e+16<cm-3> field= Boron !DelayFullD

AdvancedCalibration 

# Global Mesh settings for automatic meshing in newly generated layers
# --------------------------------------------------------------------

grid set.min.normal.size= 3<nm> set.normal.growth.ratio.2d= 1.5
mgoals accuracy= 1e-4

# screenshot of the wafer
#--------------------------

struct tdr= CMOS0

#deposition of epitaxial layer of 2.5um depth
#----------------------------------------------
deposit material= {Silicon} type= anisotropic fields.values= {Boron= 2e+15} time= 25.0<min> rate= {100<nm/min>}
struct tdr= CMOS1 ; # epitaxial layer
# Pad oxidation
# --------------

gas_flow name= H2O_O2 pressure= 1<atm> flowO2= 1<l/min> flowH2O= 1<l/min>
diffuse temperature= 950<C> time= 10<min> gas.flow= H2O_O2
struct tdr= CMOS2 ; # PadOx
# nitride layer deposition
#----------------------------
deposit material= Nitride type= anisotropic time= 12.0<min>  rate= {10<nm/min>} 
struct tdr= CMOS3 ; # Nitride layer
# masking to etch the nitride layer
#----------------------------------------
mask name= locosmask segments= {1.1 3.3 4.7 6.9} negative
# using the mask to implant the isolation areas
#-----------------------------------------------
photo mask= locosmask thickness= 1
# etching nitride layer
#--------------------------------------------
etch material= {Nitride} type= anisotropic thickness= 120<nm>
struct tdr= CMOS4 ; # etched nitride
#doping with higher concentration of boron
#----------------------------------------------
implant Boron dose= 1e13<cm-2>  energy= 50<keV> tilt= 0  rotation= 0
diffuse temperature= 1000<C> time= 10<s>

struct tdr= CMOS5 ; #just before locos
#split @LOCOS@
diffuse temperature= 1000<C> time= 100<min> gas.flow= H2O_O2
strip Resist
struct tdr= CMOS6 ; # Locos
#split @NWell@
strip Nitride
#mask used for the n-well
#------------------------------
mask name= pmosmask segments= {0 4} negative
# n-well implant
# --------------------------------------------------
photo mask = pmosmask thickness= 1
struct tdr= CMOS7 
implant  Phosphorus  dose= 2.68e12<cm-2>  energy= 180<keV> tilt= 0 rotation= 0  
diffuse temperature= 1100<C> time= 20<min>   
strip resist
struct tdr= CMOS8  ; # n-Well
#mask to cover n-well during p-channel doping
#------------------------------------------------
mask name= nmosmask segments= {4 8} negative
#using the mask during doping
#-----------------------------
photo mask= nmosmask thickness= 1
struct tdr= CMOS9
  # doping the p-channel
#---------------------------------
implant Boron dose= 5.0e12<cm-2> energy= 10<keV> tilt= 0  rotation= 0
diffuse temperature= 1000<C> time= 40<s>
strip Resist
struct tdr= CMOS10 ; # p-channel
# doping the channel in n-well
#---------------------------------
photo mask= pmosmask thickness= 1
implant Phosphorus dose= 6.4e13<cm-2> energy= 30<keV> tilt= 0  rotation= 0
diffuse temperature= 1000<C> time= 40<s>
strip Resist
# Saving structure
# ----------------
struct tdr= CMOS11  ; #after channels were doped
#the next few steps involve stripping the oxide layer that has been damaged and replacing it with a new one
#----------------------------------------------------------------------------------------------
mask name= antilocosmask segments= {0 1.1 3.3 4.7 6.9 8} negative
etch material= {Oxide}   type= anisotropic   time= 2   rate= {0.06} 
diffuse temperature= 1000<C> time= 0.7<min> O2
strip Resist
struct tdr= CMOS12
#Dry oxidation to get thin oxide layer
#--------------------------------------------------------------------------------------------

gas_flow name= O2 pressure= 1<atm> flowO2= 1<l/min>
diffuse temperature= 1050<C> time= 25<min> gas.flow= O2

struct tdr= CMOS13 ; #new thin-oxid-layer
# Poly gate deposition
# --------------------
mask name= polymask segments= {1.8 2.6 5.4 6.1} 
photo mask= polymask thickness= 1

deposit material= {PolySilicon} type= anisotropic time= 35<min> rate= {10<nm/min>} 

struct tdr= CMOS14 ; #polysilicon deposition
strip Resist
struct tdr= CMOS15 ; # PolyGate
#doping the source and drains before inputting the oxide layer to cover the polysilicon
#-----------------------------------------------------------------------------------------------
mask name= sourdrainright segments= {1.8 2.6 3.3 8} negative
mask name= sourdrainleft segments= {0 4.7 5.4 6.1} negative

photo mask= sourdrainleft thickness= 3
implant Boron dose= 3e14<cm-2> energy= 10<keV> tilt= 0 rotation= 0 
strip Resist
diffuse temp= 1100<C> time= 0.5<min>
photo mask= sourdrainright thickness= 3
implant Phosphorus dose= 8e15<cm-2> energy= 19<keV> tilt= 7 rotation= 0  
strip Resist
diffuse temp= 1100<C> time= 0.5<min>
etch material= {Oxide} type= anisotropic thickness= 0.15
#anealing step before metallization
#--------------------------------------------------------
struct tdr= CMOS16 ; #source and drain dopings
# Poly reoxidation
# ----------------
mask name= oxonpoly segments= {1.7 2.7 5.3 6.2} negative
deposit material= {SiO2} type= isotropic thickness= 0.09
photo mask= oxonpoly thickness= 3
struct tdr= sourcedrain
etch material= {Oxide} type= anisotropic thickness= 0.09 
strip Resist
struct tdr= CMOS17 ; # Polysi Reox
# Contacts
# --------
deposit material= {Aluminum} type= isotropic thickness= 0.1
struct tdr= afteralum
mask name= contacts_mask segments= {1.35 1.6 2.7 3 5 5.4 6.2 6.7} negative
photo mask= contacts_mask thickness= 3
etch material= {Aluminum} type= anisotropic thickness= 0.1
strip Resist
struct tdr= CMOS18 ; # Final
exit


