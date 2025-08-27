function state = Coolpropgit(fluid, name1, value1, name2, value2)

%   This function exports the results from the online Python version of CoolProp (https://ibell.pythonanywhere.com/) to a struct 
%   containing the estimated thermodynamic state (mass base: Temperature T [K], Pressure P [Pa], Vapor quality x [kg/kg], 
%   Speed of sound c [m/s], Specific volume v [m^3/kg], Enthalpy h [kJ/kg], Entropy s [kJ/kg/K], Constant-pressure 
%   specific heat Cp [kJ/kg/K], Constant-volume specific heat Cv [kJ/kg/K]) given two thermodynamic independient properties.
%   This has the advantage of being able to obtain thermodynamic properties without having Python installed or being 
%   able to use this function (with a simple syntax) in the online version of MathWorks apps.

%   Possible values of fluid (string):
%   "1-Butene", "Acetone", "Air", "Ammonia", "Argon", "Benzene", "CarbonDioxide", "CarbonMonoxide", "CarbonylSulfide", "CycloHexane",
%   "CycloPropane", "Cyclopentane", "D4", "D5", "D6", "Deuterium", "Dichloroethane", "DiethylEther", "DimethylCarbonate", "DimethylEther", 
%   "Ethane", "Ethanol", "EthylBenzene", "Ethylene", "EthyleneOxide", "Fluorine", "HFE143m", "HeavyWater", "Helium", "Hydrogen",
%   "HydrogenChloride", "HydrogenSulfide", "IsoButane", "IsoButene", "Isohexane", "Isopentane", "Krypton", "MD2M", "MD3M", "MD4M",
%   "MDM", "MM", "Methane", "Methanol", "MethylLinoleate", "MethylLinolenate", "MethylOleate", "MethylPalmitate", "MethylStearate", "Neon",
%   "Neopentane", "Nitrogen", "NitrousOxide", "Novec649", "OrthoDeuterium", "OrthoHydrogen", "Oxygen", "ParaDeuterium", "ParaHydrogen", "Propylene",
%   "Propyne", "R11", "R113", "R114", "R115", "R116", "R12", "R123", "R1233zd(E)", "R1234yf",
%   "R1234ze(E)", "R1234ze(Z)", "R124", "R1243zf", "R125", "R13", "R134a", "R13I1", "R14", "R141b",
%   "R142b", "R143a", "R152A", "R161", "R21", "R218", "R22", "R227EA", "R23", "R236EA",
%   "R236FA", "R245ca", "R245fa", "R32", "R365MFC", "R40", "R404A", "R407C", "R41", "R410A",
%   "R507A", "RC318", "SES36", "SulfurDioxide", "SulfurHexafluoride", "Toluene", "Water", "Xenon", "cis-2-Butene", "m-Xylene",
%   "n-Butane", "n-Decane", "n-Dodecane", "n-Heptane", "n-Hexane", "n-Nonane", "n-Octane", "n-Pentane", "n-Propane", "n-Undecane",
%   "o-Xylene", "p-Xylene", "trans-2-Butene"

%   Options for name1 and name2 (character):
%   "v" = Specific volume [m^3/kg]
%   "P" = Pressure [Pa]
%   "T" = Temperature [K]
%   "h" = Enthalpy [kJ/kg]
%   "s" = Entropy [kJ/kg/K]
%   "u" = Internal Energy [kJ/kg]
%   "x" = Vapor Quality [kg/kg]

%   value1 and value2 as double values.

%   In case of saturated liquid-vapor mixtures, c is not estimated and is reported as NaN.

%   In case of one phase, x is -1.

%   If the state cannot be calculated, it returns an empty struct and a warning.

%   Examples:
%   Water at T = 38°C and P = 9 kPa: Coolpropgit("Water", "P", 9E3, "T", 38+273.15)
%   Ammonia at s = 4 kJ/kg/K and P = 0.5 MPa: Coolpropgit("Ammonia", "s", 4, "P", 0.5E6)

    % Get the web page that calculates the state given the input:
    switch name1
        case "v"
            name1url = "Density+%28mass%29+%5Bkg%2Fm%5E3%5D";
            value1 = 1 / value1;
        case "P"
            name1url = "Pressure+%5BPa%5D";
        case "T"
            name1url = "Temperature+%5BK%5D";
        case "h"
            name1url = "Enthalpy+%5BJ%2Fkg%5D";
            value1 = value1 * 1E3;
        case "s"
            name1url = "Entropy+%5BJ%2Fkg%2FK%5D";
            value1 = value1 * 1E3;
        case "u"
            name1url = "Internal+Energy+%5BJ%2Fkg%5D";
            value1 = value1 * 1E3;
        case "x"
            name1url = "Vapor+Quality+%5Bkg%2Fkg%5D";
        otherwise
            name1url = "";
    end
    switch name2
        case "v"
            name2url = "Density+%28mass%29+%5Bkg%2Fm%5E3%5D";
            value2 = 1 / value2;
        case "P"
            name2url = "Pressure+%5BPa%5D";
        case "T"
            name2url = "Temperature+%5BK%5D";
        case "h"
            name2url = "Enthalpy+%5BJ%2Fkg%5D";
            value2 = value2 * 1E3;
        case "s"
            name2url = "Entropy+%5BJ%2Fkg%2FK%5D";
            value2 = value2 * 1E3;
        case "u"
            name2url = "Internal+Energy+%5BJ%2Fkg%5D";
            value2 = value2 * 1E3;
        case "x"
            name2url = "Vapor+Quality+%5Bkg%2Fkg%5D";
        otherwise
            name2url = "";
    end
    url = "https://ibell.pythonanywhere.com/next?fluid=" + fluid + "&name1=" + name1url + ...
        "&name2=" + name2url + "&unit_system=Mass-based&value1=" + num2str(value1) + "&value2=" + num2str(value2);
    
    % Obtain the requested thermodynamic state
    try
        data = webread(url);
        state = struct();
        T = regexp(data, "<td>Temperature \[K\]</td><td>(.*?)</td>", "tokens");
        state.T = ~isempty(T) * str2double(T{1}{1});
        P = regexp(data, "<td>Pressure \[Pa\]</td><td>(.*?)</td>", "tokens");
        state.P = ~isempty(P) * str2double(P{1}{1});
        x = regexp(data, "<td>Vapor quality \[kg/kg\]</td><td>(.*?)</td>", "tokens");
        state.x = ~isempty(x) * str2double(x{1}{1});
        c = regexp(data, "<td>Speed of sound \[m/s\]</td><td>(.*?)</td>", "tokens");
        state.c = ~isempty(c) * str2double(c{1}{1});
        rho = regexp(data, "<td>Density \[kg/m3\]</td><td>(.*?)</td>", "tokens");
        state.v = ~isempty(rho) * 1/str2double(rho{1}{1}); 
        h = regexp(data, "<td>Enthalpy \[J/kg\]</td><td>(.*?)</td>", "tokens");
        state.h = ~isempty(h) * str2double(h{1}{1}) * 1E-3; 
        s = regexp(data, "<td>Entropy \[J/kg/K\]</td><td>(.*?)</td>", "tokens");
        state.s = ~isempty(s) * str2double(s{1}{1}) * 1E-3; 
        Cp = regexp(data, "<td>Constant-pressure specific heat \[J/kg/K\]</td><td>(.*?)</td>", "tokens");
        state.Cp = ~isempty(Cp) * str2double(Cp{1}{1}) * 1E-3; 
        Cv = regexp(data, "<td>Constant-volume specific heat \[J/kg/K\]</td><td>(.*?)</td>", "tokens");
        state.Cv = ~isempty(Cv) * str2double(Cv{1}{1}) * 1E-3;
        state.units = "T [K], P [Pa], x [kg/kg], c [m/s], v [m^3/kg], h [kJ/kg], s [kJ/kg/K], Cp [kJ/kg/K], Cv [kJ/kg/K]";
    catch
        warning("It was not possible to estimate the thermodynamic state.");
    end

end