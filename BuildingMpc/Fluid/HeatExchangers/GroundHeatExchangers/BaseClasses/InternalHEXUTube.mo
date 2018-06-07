within BuildingMpc.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses;
model InternalHEXUTube
  "Internal part of a borehole for a U-Tube configuration"

  extends IBPSA.Fluid.Interfaces.FourPortHeatMassExchanger(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    T1_start=T_start,
    T2_start=T_start,
    final tau1=Modelica.Constants.pi*borFieDat.conDat.rTub^2*borFieDat.conDat.hSeg*rho1_nominal/
        m1_flow_nominal,
    final tau2=Modelica.Constants.pi*borFieDat.conDat.rTub^2*borFieDat.conDat.hSeg*rho2_nominal/
        m2_flow_nominal,
    final vol1(
      final energyDynamics=energyDynamics,
      final massDynamics=massDynamics,
      final prescribedHeatFlowRate=false,
      final m_flow_small=m1_flow_small,
      final V=borFieDat.conDat.volOneLegSeg,
      final mSenFac=mSenFac),
    redeclare final IBPSA.Fluid.MixingVolumes.MixingVolume vol2(
      final energyDynamics=energyDynamics,
      final massDynamics=massDynamics,
      final prescribedHeatFlowRate=false,
      final m_flow_small=m2_flow_small,
      final V=borFieDat.conDat.volOneLegSeg,
      final mSenFac=mSenFac));
  replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium "Medium"
      annotation (choicesAllMatching = true);
  parameter Real mSenFac=1
      "Factor for scaling the sensible thermal mass of the volume"
      annotation (Dialog(group="Advanced"));
  parameter Boolean dynFil=true
      "Set to false to remove the dynamics of the filling material"
      annotation (Dialog(tab="Dynamics"));
  parameter Modelica.SIunits.Temperature T_start
    "Initial temperature of the filling material and fluid"
    annotation (Dialog(group="Filling material"));
  parameter
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.BorefieldData.Template
    borFieDat "Borefield parameters"
    annotation (Placement(transformation(extent={{-100,-120},{-80,-100}})));

  Modelica.Blocks.Sources.RealExpression RVol1(y=
   BuildingMpc.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.convectionResistance(
            hSeg=borFieDat.conDat.hSeg,
            rBor=borFieDat.conDat.rBor,
            rTub=borFieDat.conDat.rTub,
            eTub=borFieDat.conDat.eTub,
            kMed=kMed,
            mueMed=mueMed,
            cpMed=cpMed,
            m_flow_nominal=m1_flow_nominal))
    "Convective and thermal resistance at fluid 1"
    annotation (Placement(transformation(extent={{-100,-2},{-80,18}})));
  Modelica.Blocks.Sources.RealExpression RVol2(y=
   BuildingMpc.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.convectionResistance(
            hSeg=borFieDat.conDat.hSeg,
            rBor=borFieDat.conDat.rBor,
            rTub=borFieDat.conDat.rTub,
            eTub=borFieDat.conDat.eTub,
            kMed=kMed,
            mueMed=mueMed,
            cpMed=cpMed,
            m_flow_nominal=m2_flow_nominal))
    "Convective and thermal resistance at fluid 2"
     annotation (Placement(transformation(extent={{-100,-18},{-80,2}})));

  IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BaseClasses.InternalResistancesOneUTube
    intResUTub(
    dynFil=dynFil,
    T_start=T_start,
    energyDynamics=energyDynamics,
    Rgb_val=Rgb_val,
    Rgg_val=Rgg_val,
    RCondGro_val=RCondGro_val,
    x=x,
    borFieDat=borFieDat)
    "Internal resistances for a single U-tube configuration"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Thermal.HeatTransfer.Components.ConvectiveResistor RConv2
    "Pipe convective resistance"
    annotation (Placement(transformation(extent={{-12,12},{12,-12}},
        rotation=270,
        origin={0,-28})));
  Modelica.Thermal.HeatTransfer.Components.ConvectiveResistor RConv1
    "Pipe convective resistance"
    annotation (Placement(transformation(extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,28})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a port_wall
    "Thermal connection for borehole wall"
    annotation (Placement(transformation(extent={{-10,90},{10,110}})));

protected
  parameter Modelica.SIunits.HeatCapacity Co_fil=borFieDat.filDat.d*borFieDat.filDat.c*borFieDat.conDat.hSeg*Modelica.Constants.pi
      *(borFieDat.conDat.rBor^2 - 2*(borFieDat.conDat.rTub + borFieDat.conDat.eTub)^2)
    "Heat capacity of the whole filling material";

  parameter Modelica.SIunits.SpecificHeatCapacity cpMed=
      Medium.specificHeatCapacityCp(Medium.setState_pTX(
      Medium.p_default,
      Medium.T_default,
      Medium.X_default)) "Specific heat capacity of the fluid";
  parameter Modelica.SIunits.ThermalConductivity kMed=
      Medium.thermalConductivity(Medium.setState_pTX(
      Medium.p_default,
      Medium.T_default,
      Medium.X_default)) "Thermal conductivity of the fluid";
  parameter Modelica.SIunits.DynamicViscosity mueMed=Medium.dynamicViscosity(
      Medium.setState_pTX(
      Medium.p_default,
      Medium.T_default,
      Medium.X_default)) "Dynamic viscosity of the fluid";

 parameter Real Rgb_val = (1 - x)*Rg
    "Thermal resistance between grout zone and borehole wall";
  parameter Real Rgg_val = 2*Rgb_val*(Rar - 2*x*Rg)/(2*Rgb_val - Rar + 2*x*Rg) "Thermal resistance between the two grout zones";
  parameter Real RCondGro_val =  x*Rg + RCondPipe/borFieDat.conDat.hSeg
    "Thermal resistance between: pipe wall to capacity in grout";
  parameter Real x = Modelica.Math.log(sqrt(borFieDat.conDat.rBor^2 + 2*borFieDat.conDat.rTub^2)/(2*borFieDat.conDat.rTub))/
      Modelica.Math.log(borFieDat.conDat.rBor/(sqrt(2)*borFieDat.conDat.rTub)) "Capacity location";

  // ********** Rb and Ra from multipole **********
  // Help variables
  parameter Real sigma= (borFieDat.filDat.k - borFieDat.soiDat.k)/(borFieDat.filDat.k + borFieDat.soiDat.k);

  parameter Real rTub_in = borFieDat.conDat.rTub-borFieDat.conDat.eTub "Inner radius of tube";

  parameter Real RCondPipe(unit="(m.K)/W") =  Modelica.Math.log((borFieDat.conDat.rTub)/rTub_in)/(2*Modelica.Constants.pi*borFieDat.conDat.kTub)
    "Thermal resistance of the pipe wall";
  parameter Real RConv = BuildingMpc.Fluid.HeatExchangers.GroundHeatExchangers.BaseClasses.convectionResistance(
            hSeg=borFieDat.conDat.hSeg,
            rBor=borFieDat.conDat.rBor,
            rTub=borFieDat.conDat.rTub,
            eTub=borFieDat.conDat.eTub,
            kMed=kMed,
            mueMed=mueMed,
            cpMed=cpMed,
            m_flow_nominal=(m1_flow_nominal+m2_flow_nominal)/2);

  parameter Real beta= 2*Modelica.Constants.pi*borFieDat.filDat.k*(RCondPipe+RConv);

  parameter Real R_1delta_LS= 1/(2*Modelica.Constants.pi*borFieDat.filDat.k)*(log(borFieDat.conDat.rBor/borFieDat.conDat.rTub) + log(borFieDat.conDat.rBor/(2*borFieDat.conDat.xC)) +
    sigma*log(borFieDat.conDat.rBor^4/(borFieDat.conDat.rBor^4 - borFieDat.conDat.xC^4))) + RCondPipe + RConv;

  parameter Real R_1delta_MP= R_1delta_LS - 1/(2*Modelica.Constants.pi*borFieDat.filDat.k)*(borFieDat.conDat.rTub^2/
    (4*borFieDat.conDat.xC^2)*(1 - sigma*4*borFieDat.conDat.xC^4/(borFieDat.conDat.rBor^4 - borFieDat.conDat.xC^4))^2)/((1 + beta)/(1 - beta) +
    borFieDat.conDat.rTub^2/(4*borFieDat.conDat.xC^2)*(1 + sigma*16*borFieDat.conDat.xC^4*borFieDat.conDat.rBor^4/(borFieDat.conDat.rBor^4 - borFieDat.conDat.xC^4)^2));

  parameter Real Ra_LS =     1/(Modelica.Constants.pi*borFieDat.filDat.k)*(log(2*borFieDat.conDat.xC/borFieDat.conDat.rTub) + sigma*log((
    borFieDat.conDat.rBor^2 + borFieDat.conDat.xC^2)/(borFieDat.conDat.rBor^2 - borFieDat.conDat.xC^2)))  + 2*(RCondPipe + RConv);

  //Rb and Ra
  parameter Real Rb_internal= if borFieDat.conDat.use_Rb then borFieDat.conDat.Rb else R_1delta_MP/2;
  parameter Real Ra= Ra_LS - 1/(Modelica.Constants.pi*borFieDat.filDat.k)*(borFieDat.conDat.rTub^2/(4*borFieDat.conDat.xC^2)*(1 + sigma*
    4*borFieDat.conDat.rBor^4*borFieDat.conDat.xC^2/(borFieDat.conDat.rBor^4 - borFieDat.conDat.xC^4))/((1 + beta)/(1 - beta) - borFieDat.conDat.rTub^2/(4*borFieDat.conDat.xC^2) +
    sigma*2*borFieDat.conDat.rTub^2*borFieDat.conDat.rBor^2*(borFieDat.conDat.rBor^4 + borFieDat.conDat.xC^4)/(borFieDat.conDat.rBor^4 - borFieDat.conDat.xC^4)^2));

  //Conversion of Rb (resp. Ra) to Rg (resp. Rar) of Bauer:
  parameter Real Rg = (2*Rb_internal-RCondPipe-RConv)/borFieDat.conDat.hSeg;
  parameter Real Rar= (Ra-2*(RCondPipe + RConv))/borFieDat.conDat.hSeg;

equation
    assert(borFieDat.conDat.borHolCon == IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Types.BoreHoleConfiguration.SingleUTube,
  "This model should be used for single U-type borefield, not double U-type. 
  Check that the record General has been correctly parametrized");
  if dynFil then
  end if;

  connect(RVol2.y, RConv2.Rc) annotation (Line(points={{-79,-8},{-60,-8},{-40,
          -8},{-40,-28},{-12,-28}},
                                color={0,0,127}));
  connect(RVol1.y, RConv1.Rc) annotation (Line(points={{-79,8},{-40,8},{-40,28},
          {-12,28}}, color={0,0,127}));
  connect(intResUTub.port_wall, port_wall) annotation (Line(points={{10,0},{26,
          0},{40,0},{40,100},{0,100}}, color={191,0,0}));
  connect(vol1.heatPort, RConv1.fluid) annotation (Line(points={{-10,60},{-20,
          60},{-20,40},{6.66134e-016,40}}, color={191,0,0}));
  connect(RConv1.solid, intResUTub.port_1)
    annotation (Line(points={{0,16},{0,16},{0,10}}, color={191,0,0}));
  connect(RConv2.fluid, vol2.heatPort) annotation (Line(points={{0,-40},{20,-40},
          {20,-60},{12,-60}}, color={191,0,0}));
  connect(RConv2.solid, intResUTub.port_2)
    annotation (Line(points={{0,-16},{0,-16},{0,-10}}, color={191,0,0}));
    annotation (Dialog(tab="Dynamics"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},{100,
            100}})),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},{100,
            100}}), graphics={Rectangle(
          extent={{88,54},{-88,64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid), Rectangle(
          extent={{88,-66},{-88,-56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid)}),
    Documentation(info="<html>
<p>
Model for the heat transfer between the fluid and within the borehole filling. 
This model computes the dynamic response of the fluid in the tubes, 
the heat transfer between the fluid and the borehole filling, 
and the heat storage within the fluid and the borehole filling.
</p>
<p>
This model computes the different thermal resistances present 
in a single-U-tube borehole using the method of Bauer et al. (2011) 
and computing explicitely the fluid-to-ground thermal resistance 
<i>R<sub>b</sub></i> and the 
grout-to-grout resistance
<i>R<sub>a</sub></i> as defined by Hellstroem (1991)
using the multipole method.
The multipole method is implemented in
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Boreholes.BaseClasses.singleUTubeResistances\">
IBPSA.Fluid.HeatExchangers.Boreholes.BaseClasses.singleUTubeResistances</a>. 
The convection resistance is calculated using the 
Dittus-Boelter correlation
as implemented in
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.Boreholes.BaseClasses.convectionResistance\">
IBPSA.Fluid.HeatExchangers.Boreholes.BaseClasses.convectionResistance</a>. 
</p>
<p>
The figure below shows the thermal network set up by Bauer et al. (2010).
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://IDEAS/Resources/Images/Fluid/HeatExchangers/Boreholes/BaseClasses/Bauer_singleUTube.png\"/>
</p>
<h4>References</h4>
<p>
G. Hellstr&ouml;m. 
<i>Ground heat storage: thermal analyses of duct storage systems (Theory)</i>. 
Dept. of Mathematical Physics, University of Lund, Sweden, 1991.
</p>
<p>
D. Bauer, W. Heidemann, H. M&uuml;ller-Steinhagen, and H.-J. G. Diersch.
<i>
<a href=\"http://dx.doi.org/10.1002/er.1689\">
Thermal resistance and capacity models for borehole heat exchangers
</a>
</i>.
International Journal Of Energy Research, 35:312&ndash;320, 2011.
</p>
</html>", revisions="<html>
<p>
<ul>
<li>
June 18, 2014, by Michael Wetter:<br/>
Added initialization for temperatures and derivatives of <code>capFil1</code>
and <code>capFil2</code> to avoid a warning during translation.
</li>
<li>
February 14, 2014, by Michael Wetter:<br/>
Removed unused parameters <code>B0</code> and <code>B1</code>.
</li>
<li>
January 24, 2014, by Michael Wetter:<br/>
Revised implementation, added comments, replaced 
<code>HeatTransfer.Windows.BaseClasses.ThermalConductor</code>
with resistance models from the Modelica Standard Library.
</li>
<li>
January 23, 2014, by Damien Picard:<br/>
First implementation.
</li>
</ul>
</p>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}), graphics));
end InternalHEXUTube;
