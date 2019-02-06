within BuildingMpc.Fluid.Geothermal.Borefields.Linear.Validation;
model InfraxValidation
  extends Modelica.Icons.Example
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
  package Medium = IBPSA.Media.Antifreeze.PropyleneGlycolWater(property_T=283.15, X_a=0.30);
  parameter String fileName = Modelica.Utilities.Files.loadResource("modelica://BuildingMpc/Fluid/Geothermal/Borefields/Linear/SSM/Infrax/ssm.mat");
  parameter Modelica.SIunits.TemperatureDifference dT = 3;
  final parameter Integer nSta = Bsize[1] "Number of states";
  final parameter Integer nInp = Bsize[2] "Number of inputs";
  final parameter Integer nPreInp = 0 "Number of precomputed inputs";
  final parameter Integer nOut = Csize[1] "Number of precomputed outputs";

   Modelica.Blocks.Continuous.StateSpace borFieSSM(
    A=readMatrix(
        fileName=fileName,
        matrixName="A",
        rows=nSta,
        columns=nSta),
    B=readMatrix(
        fileName=fileName,
        matrixName="B",
        rows=nSta,
        columns=nInp),
    C=readMatrix(
        fileName=fileName,
        matrixName="C",
        rows=nOut,
        columns=nSta),
    D=readMatrix(
        fileName=fileName,
        matrixName="D",
        rows=nOut,
        columns=nInp),
    x_start=x_start,
    initType=Modelica.Blocks.Types.Init.NoInit) "State space model"
    annotation (Placement(transformation(extent={{-20,60},{0,80}})));
  Real emu_states[190];
  Real NL_states[190];
protected
  parameter Real x_start[nSta](each fixed=false) "Initial state values";
  final parameter Integer[2] Bsize = readMatrixSize(fileName=fileName, matrixName="B") "Size of B matrix of state space model";
  final parameter Integer[2] Csize = readMatrixSize(fileName=fileName, matrixName="C") "Size of C matrix of state space model";

public
  Modelica.Blocks.Math.Add err(k1=-1)
    annotation (Placement(transformation(extent={{40,20},{60,40}})));
  Modelica.Blocks.Interfaces.RealOutput error
    annotation (Placement(transformation(extent={{100,20},{120,40}})));
  INFRAX.Data.Parameters.BorefieldData.INFRAX_bF iNFRAX_bF
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  TwoUTube borFieNLC(
    borFieDat=iNFRAX_bF,
    allowFlowReversal=false,
    redeclare package Medium = Medium,
    show_T=true,
    energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
    dynFil=true,
    TExt0_start=13.3 + 273.15,
    z0=10,
    dT_dz=0.01)
    annotation (Placement(transformation(extent={{-30,-40},{10,0}})));
  IDEAS.Fluid.Sensors.TemperatureTwoPort TInNLC(
    redeclare package Medium = Medium,
    tau=0,
    allowFlowReversal=false,
    m_flow_nominal=iNFRAX_bF.conDat.mBorFie_flow_nominal)
    annotation (Placement(transformation(extent={{-60,-30},{-40,-10}})));
  IDEAS.Fluid.Sensors.TemperatureTwoPort TOutNLC(
    allowFlowReversal=false,
    m_flow_nominal=iNFRAX_bF.conDat.mBorFie_flow_nominal,
    redeclare package Medium = Medium,
    tau=0) annotation (Placement(transformation(extent={{20,-30},{40,-10}})));
  IDEAS.Fluid.Sources.Boundary_pT sou(
    redeclare package Medium = Medium,
    use_T_in=true,
    nPorts=1)
    annotation (Placement(transformation(extent={{-90,-30},{-70,-10}})));
  IDEAS.Fluid.Sources.Boundary_pT sink(redeclare package Medium = Medium,
      nPorts=1)
    annotation (Placement(transformation(extent={{100,-30},{80,-10}})));
protected
  IDEAS.Fluid.Movers.BaseClasses.IdealSource mFlowNLC(
    final allowFlowReversal=false,
    final control_m_flow=true,
    final m_flow_small=1e-04,
    redeclare final package Medium = Medium,
    control_dp=false) "Pressure source"
    annotation (Placement(transformation(extent={{50,-30},{70,-10}})));
public
  Modelica.Blocks.Sources.RealExpression realExpression2(y=borFieNLC.borHol.sta_b.T)
    annotation (Placement(transformation(extent={{4,14},{24,34}})));
  IDEAS.Utilities.Time.ModelTime modTim
    annotation (Placement(transformation(extent={{-150,58},{-130,78}})));
  Modelica.Blocks.Tables.CombiTable1Ds combiTable2D(
    tableOnFile=true,
    tableName="data",
    fileName=ModelicaServices.ExternalReferences.loadResource("modelica://INFRAX/Resources/Validation/borefield_validation.txt"),
    columns={2,3,4,5,6,7})
    annotation (Placement(transformation(extent={{-108,58},{-88,78}})));

  Modelica.Blocks.Sources.Constant cToK(k=273.15)
    annotation (Placement(transformation(extent={{-76,46},{-64,58}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{-56,60},{-36,80}})));
public
  Modelica.Blocks.Sources.RealExpression realExpression1(y=Medium.d_const)
    annotation (Placement(transformation(extent={{-80,86},{-60,106}})));
  Modelica.Blocks.Math.Gain        cToK1(k=10/3600*Medium.d_const/1000)
    annotation (Placement(transformation(extent={{-18,18},{-6,30}})));
  IDEAS.Fluid.Sources.Boundary_pT sou1(
    redeclare package Medium = Medium,
    use_T_in=true,
    nPorts=1)
    annotation (Placement(transformation(extent={{-90,-90},{-70,-70}})));
  IDEAS.Fluid.Sensors.TemperatureTwoPort TInEmu(
    redeclare package Medium = Medium,
    tau=0,
    allowFlowReversal=false,
    m_flow_nominal=iNFRAX_bF.conDat.mBorFie_flow_nominal)
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));
  IBPSA.Fluid.Geothermal.Borefields.TwoUTubes borFieEmu(
    borFieDat=iNFRAX_bF,
    allowFlowReversal=false,
    redeclare package Medium = Medium,
    show_T=true,
    r=cat(
        1,
        borFieNLC.lay[1].rC,
        {borFieNLC.r_b}),
    nbTem=11,
    TExt0_start=13.3 + 273.15)
    annotation (Placement(transformation(extent={{-30,-100},{10,-60}})));
  IDEAS.Fluid.Sensors.TemperatureTwoPort TOutEmu(
    allowFlowReversal=false,
    m_flow_nominal=iNFRAX_bF.conDat.mBorFie_flow_nominal,
    redeclare package Medium = Medium,
    tau=0) annotation (Placement(transformation(extent={{20,-90},{40,-70}})));
protected
  IDEAS.Fluid.Movers.BaseClasses.IdealSource mFlowEmu(
    final allowFlowReversal=false,
    final control_m_flow=true,
    final m_flow_small=1e-04,
    redeclare final package Medium = Medium,
    control_dp=false) "Pressure source"
    annotation (Placement(transformation(extent={{50,-90},{70,-70}})));
public
  IDEAS.Fluid.Sources.Boundary_pT sink1(redeclare package Medium = Medium,
      nPorts=1)
    annotation (Placement(transformation(extent={{100,-90},{80,-70}})));
  Modelica.Blocks.Interfaces.RealOutput QBorAbs
    annotation (Placement(transformation(extent={{100,-126},{120,-106}})));
  Modelica.Blocks.Interfaces.RealOutput QMeaAbs
    annotation (Placement(transformation(extent={{100,-142},{120,-122}})));
  Modelica.Blocks.Interfaces.RealOutput QBor
    annotation (Placement(transformation(extent={{100,-170},{120,-150}})));
  Modelica.Blocks.Interfaces.RealOutput QMea
    annotation (Placement(transformation(extent={{100,-186},{120,-166}})));
  Modelica.Blocks.Interfaces.RealOutput QCal
    annotation (Placement(transformation(extent={{100,-200},{120,-180}})));
  Modelica.Blocks.Sources.RealExpression QborAbs(y=if mFlowEmu.m_flow >= 4.3
         or combiTable2D.y[6] > 0 then abs((combiTable2D.y[2] - (borFieEmu.sta_b.T
         - 273.15)))*mFlowEmu.m_flow*Medium.cp_const/1000 else 0)
    annotation (Placement(transformation(extent={{-40,-120},{-20,-100}})));
  Modelica.Blocks.Sources.RealExpression QmeaAbs(y=if mFlowEmu.m_flow >= 4.3
         or combiTable2D.y[6] > 0 then abs(combiTable2D.y[2] - combiTable2D.y[1])
        *mFlowEmu.m_flow*Medium.cp_const/1000 else 0)
    annotation (Placement(transformation(extent={{-40,-140},{-20,-120}})));
  INFRAX.SubSystems.VentilationSystem.Components.Dependencies.Integrator
                                                                  integrator5(k=1/3600/
        1000)
    annotation (Placement(transformation(extent={{0,-120},{20,-100}})));
  INFRAX.SubSystems.VentilationSystem.Components.Dependencies.Integrator
                                                                  integrator4(k=1/3600/
        1000)
    annotation (Placement(transformation(extent={{0,-140},{20,-120}})));
  Modelica.Blocks.Math.Gain convFacCal(k=1/100) "conversionfactor caloriemeter"
    annotation (Placement(transformation(extent={{-44,-200},{-24,-180}})));
  INFRAX.SubSystems.VentilationSystem.Components.Dependencies.Integrator
                                                                  integrator1(k=1/3600/
        1000)
    annotation (Placement(transformation(extent={{0,-160},{20,-140}})));
  INFRAX.SubSystems.VentilationSystem.Components.Dependencies.Integrator
                                                                  integrator2(k=1/3600/
        1000)
    annotation (Placement(transformation(extent={{0,-180},{20,-160}})));
  INFRAX.SubSystems.VentilationSystem.Components.Dependencies.Integrator
                                                                  integrator3(k=1/3600/
        1000)
    annotation (Placement(transformation(extent={{0,-200},{20,-180}})));
  Modelica.Blocks.Sources.RealExpression Qmea(y=if mFlowEmu.m_flow >= 4.3 or
        combiTable2D.y[6] > 0 then (combiTable2D.y[2] - combiTable2D.y[1])*
        mFlowEmu.m_flow*Medium.cp_const/1000 else 0)
    annotation (Placement(transformation(extent={{-40,-180},{-20,-160}})));
  Modelica.Blocks.Sources.RealExpression Qbor(y=if mFlowEmu.m_flow >= 4.3 or
        combiTable2D.y[6] > 0 then (combiTable2D.y[2] - (borFieEmu.sta_b.T -
        273.15))*mFlowEmu.m_flow*Medium.cp_const/1000 else 0)
    annotation (Placement(transformation(extent={{-40,-160},{-20,-140}})));
public
  Modelica.Blocks.Sources.RealExpression[190] realExpression3(y=emu_states -
        NL_states)
    annotation (Placement(transformation(extent={{50,74},{70,94}})));
public
  Modelica.Blocks.Sources.RealExpression[190] realExpression4(y=emu_states -
        borFieSSM.x)
    annotation (Placement(transformation(extent={{50,52},{70,72}})));
  Modelica.Blocks.Interfaces.RealOutput[190] NL_xe
    annotation (Placement(transformation(extent={{100,74},{120,94}})));
  Modelica.Blocks.Interfaces.RealOutput[190] lin_xe
    annotation (Placement(transformation(extent={{100,52},{120,72}})));
initial algorithm
   x_start :={borFieNLC.borHol.intHex[1].vol1.T,borFieNLC.borHol.intHex[1].vol2.T,
    borFieNLC.borHol.intHex[1].vol3.T,borFieNLC.borHol.intHex[1].vol4.T,
    borFieNLC.borHol.intHex[2].vol1.T,borFieNLC.borHol.intHex[2].vol2.T,
    borFieNLC.borHol.intHex[2].vol3.T,borFieNLC.borHol.intHex[2].vol4.T,
    borFieNLC.borHol.intHex[3].vol1.T,borFieNLC.borHol.intHex[3].vol2.T,
    borFieNLC.borHol.intHex[3].vol3.T,borFieNLC.borHol.intHex[3].vol4.T,
    borFieNLC.borHol.intHex[4].vol1.T,borFieNLC.borHol.intHex[4].vol2.T,
    borFieNLC.borHol.intHex[4].vol3.T,borFieNLC.borHol.intHex[4].vol4.T,
    borFieNLC.borHol.intHex[5].vol1.T,borFieNLC.borHol.intHex[5].vol2.T,
    borFieNLC.borHol.intHex[5].vol3.T,borFieNLC.borHol.intHex[5].vol4.T,
    borFieNLC.borHol.intHex[6].vol1.T,borFieNLC.borHol.intHex[6].vol2.T,
    borFieNLC.borHol.intHex[6].vol3.T,borFieNLC.borHol.intHex[6].vol4.T,
    borFieNLC.borHol.intHex[7].vol1.T,borFieNLC.borHol.intHex[7].vol2.T,
    borFieNLC.borHol.intHex[7].vol3.T,borFieNLC.borHol.intHex[7].vol4.T,
    borFieNLC.borHol.intHex[8].vol1.T,borFieNLC.borHol.intHex[8].vol2.T,
    borFieNLC.borHol.intHex[8].vol3.T,borFieNLC.borHol.intHex[8].vol4.T,
    borFieNLC.borHol.intHex[9].vol1.T,borFieNLC.borHol.intHex[9].vol2.T,
    borFieNLC.borHol.intHex[9].vol3.T,borFieNLC.borHol.intHex[9].vol4.T,
    borFieNLC.borHol.intHex[10].vol1.T,borFieNLC.borHol.intHex[10].vol2.T,
    borFieNLC.borHol.intHex[10].vol3.T,borFieNLC.borHol.intHex[10].vol4.T,
    borFieNLC.lay[1].T[1],borFieNLC.lay[1].T[2],borFieNLC.lay[1].T[3],borFieNLC.lay[
    1].T[4],borFieNLC.lay[1].T[5],borFieNLC.lay[1].T[6],borFieNLC.lay[1].T[7],
    borFieNLC.lay[1].T[8],borFieNLC.lay[1].T[9],borFieNLC.lay[1].T[10],
    borFieNLC.lay[2].T[1],borFieNLC.lay[2].T[2],borFieNLC.lay[2].T[3],borFieNLC.lay[
    2].T[4],borFieNLC.lay[2].T[5],borFieNLC.lay[2].T[6],borFieNLC.lay[2].T[7],
    borFieNLC.lay[2].T[8],borFieNLC.lay[2].T[9],borFieNLC.lay[2].T[10],
    borFieNLC.lay[3].T[1],borFieNLC.lay[3].T[2],borFieNLC.lay[3].T[3],borFieNLC.lay[
    3].T[4],borFieNLC.lay[3].T[5],borFieNLC.lay[3].T[6],borFieNLC.lay[3].T[7],
    borFieNLC.lay[3].T[8],borFieNLC.lay[3].T[9],borFieNLC.lay[3].T[10],
    borFieNLC.lay[4].T[1],borFieNLC.lay[4].T[2],borFieNLC.lay[4].T[3],borFieNLC.lay[
    4].T[4],borFieNLC.lay[4].T[5],borFieNLC.lay[4].T[6],borFieNLC.lay[4].T[7],
    borFieNLC.lay[4].T[8],borFieNLC.lay[4].T[9],borFieNLC.lay[4].T[10],
    borFieNLC.lay[5].T[1],borFieNLC.lay[5].T[2],borFieNLC.lay[5].T[3],borFieNLC.lay[
    5].T[4],borFieNLC.lay[5].T[5],borFieNLC.lay[5].T[6],borFieNLC.lay[5].T[7],
    borFieNLC.lay[5].T[8],borFieNLC.lay[5].T[9],borFieNLC.lay[5].T[10],
    borFieNLC.lay[6].T[1],borFieNLC.lay[6].T[2],borFieNLC.lay[6].T[3],borFieNLC.lay[
    6].T[4],borFieNLC.lay[6].T[5],borFieNLC.lay[6].T[6],borFieNLC.lay[6].T[7],
    borFieNLC.lay[6].T[8],borFieNLC.lay[6].T[9],borFieNLC.lay[6].T[10],
    borFieNLC.lay[7].T[1],borFieNLC.lay[7].T[2],borFieNLC.lay[7].T[3],borFieNLC.lay[
    7].T[4],borFieNLC.lay[7].T[5],borFieNLC.lay[7].T[6],borFieNLC.lay[7].T[7],
    borFieNLC.lay[7].T[8],borFieNLC.lay[7].T[9],borFieNLC.lay[7].T[10],
    borFieNLC.lay[8].T[1],borFieNLC.lay[8].T[2],borFieNLC.lay[8].T[3],borFieNLC.lay[
    8].T[4],borFieNLC.lay[8].T[5],borFieNLC.lay[8].T[6],borFieNLC.lay[8].T[7],
    borFieNLC.lay[8].T[8],borFieNLC.lay[8].T[9],borFieNLC.lay[8].T[10],
    borFieNLC.lay[9].T[1],borFieNLC.lay[9].T[2],borFieNLC.lay[9].T[3],borFieNLC.lay[
    9].T[4],borFieNLC.lay[9].T[5],borFieNLC.lay[9].T[6],borFieNLC.lay[9].T[7],
    borFieNLC.lay[9].T[8],borFieNLC.lay[9].T[9],borFieNLC.lay[9].T[10],
    borFieNLC.lay[10].T[1],borFieNLC.lay[10].T[2],borFieNLC.lay[10].T[3],
    borFieNLC.lay[10].T[4],borFieNLC.lay[10].T[5],borFieNLC.lay[10].T[6],
    borFieNLC.lay[10].T[7],borFieNLC.lay[10].T[8],borFieNLC.lay[10].T[9],
    borFieNLC.lay[10].T[10],borFieNLC.Cground[1].T,borFieNLC.Cground[2].T,
    borFieNLC.Cground[3].T,borFieNLC.Cground[4].T,borFieNLC.Cground[5].T,
    borFieNLC.Cground[6].T,borFieNLC.Cground[7].T,borFieNLC.Cground[8].T,
    borFieNLC.Cground[9].T,borFieNLC.Cground[10].T,borFieNLC.borHol.intHex[1].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[1].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[1].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[1].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[2].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[2].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[2].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[2].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[3].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[3].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[3].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[3].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[4].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[4].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[4].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[4].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[5].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[5].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[5].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[5].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[6].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[6].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[6].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[6].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[7].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[7].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[7].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[7].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[8].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[8].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[8].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[8].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[9].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[9].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[9].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[9].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[10].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[10].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[
    10].intRes2UTub.capFil3.T,borFieNLC.borHol.intHex[10].intRes2UTub.capFil4.T};
equation

  emu_states = {borFieEmu.borHol.intHex[1].vol1.T,
borFieEmu.borHol.intHex[1].vol2.T,
borFieEmu.borHol.intHex[1].vol3.T,
borFieEmu.borHol.intHex[1].vol4.T,
borFieEmu.borHol.intHex[2].vol1.T,
borFieEmu.borHol.intHex[2].vol2.T,
borFieEmu.borHol.intHex[2].vol3.T,
borFieEmu.borHol.intHex[2].vol4.T,
borFieEmu.borHol.intHex[3].vol1.T,
borFieEmu.borHol.intHex[3].vol2.T,
borFieEmu.borHol.intHex[3].vol3.T,
borFieEmu.borHol.intHex[3].vol4.T,
borFieEmu.borHol.intHex[4].vol1.T,
borFieEmu.borHol.intHex[4].vol2.T,
borFieEmu.borHol.intHex[4].vol3.T,
borFieEmu.borHol.intHex[4].vol4.T,
borFieEmu.borHol.intHex[5].vol1.T,
borFieEmu.borHol.intHex[5].vol2.T,
borFieEmu.borHol.intHex[5].vol3.T,
borFieEmu.borHol.intHex[5].vol4.T,
borFieEmu.borHol.intHex[6].vol1.T,
borFieEmu.borHol.intHex[6].vol2.T,
borFieEmu.borHol.intHex[6].vol3.T,
borFieEmu.borHol.intHex[6].vol4.T,
borFieEmu.borHol.intHex[7].vol1.T,
borFieEmu.borHol.intHex[7].vol2.T,
borFieEmu.borHol.intHex[7].vol3.T,
borFieEmu.borHol.intHex[7].vol4.T,
borFieEmu.borHol.intHex[8].vol1.T,
borFieEmu.borHol.intHex[8].vol2.T,
borFieEmu.borHol.intHex[8].vol3.T,
borFieEmu.borHol.intHex[8].vol4.T,
borFieEmu.borHol.intHex[9].vol1.T,
borFieEmu.borHol.intHex[9].vol2.T,
borFieEmu.borHol.intHex[9].vol3.T,
borFieEmu.borHol.intHex[9].vol4.T,
borFieEmu.borHol.intHex[10].vol1.T,
borFieEmu.borHol.intHex[10].vol2.T,
borFieEmu.borHol.intHex[10].vol3.T,
borFieEmu.borHol.intHex[10].vol4.T,
borFieEmu.TSoi[2, 1],
borFieEmu.TSoi[3, 1],
borFieEmu.TSoi[4, 1],
borFieEmu.TSoi[5, 1],
borFieEmu.TSoi[6, 1],
borFieEmu.TSoi[7, 1],
borFieEmu.TSoi[8, 1],
borFieEmu.TSoi[9, 1],
borFieEmu.TSoi[10, 1],
borFieEmu.TSoi[11, 1],
borFieEmu.TSoi[2, 2],
borFieEmu.TSoi[3, 2],
borFieEmu.TSoi[4, 2],
borFieEmu.TSoi[5, 2],
borFieEmu.TSoi[6, 2],
borFieEmu.TSoi[7, 2],
borFieEmu.TSoi[8, 2],
borFieEmu.TSoi[9, 2],
borFieEmu.TSoi[10, 2],
borFieEmu.TSoi[11, 2],
borFieEmu.TSoi[2, 3],
borFieEmu.TSoi[3, 3],
borFieEmu.TSoi[4, 3],
borFieEmu.TSoi[5, 3],
borFieEmu.TSoi[6, 3],
borFieEmu.TSoi[7, 3],
borFieEmu.TSoi[8, 3],
borFieEmu.TSoi[9, 3],
borFieEmu.TSoi[10, 3],
borFieEmu.TSoi[11, 3],
borFieEmu.TSoi[2, 4],
borFieEmu.TSoi[3, 4],
borFieEmu.TSoi[4, 4],
borFieEmu.TSoi[5, 4],
borFieEmu.TSoi[6, 4],
borFieEmu.TSoi[7, 4],
borFieEmu.TSoi[8, 4],
borFieEmu.TSoi[9, 4],
borFieEmu.TSoi[10, 4],
borFieEmu.TSoi[11, 4],
borFieEmu.TSoi[2, 5],
borFieEmu.TSoi[3, 5],
borFieEmu.TSoi[4, 5],
borFieEmu.TSoi[5, 5],
borFieEmu.TSoi[6, 5],
borFieEmu.TSoi[7, 5],
borFieEmu.TSoi[8, 5],
borFieEmu.TSoi[9, 5],
borFieEmu.TSoi[10, 5],
borFieEmu.TSoi[11, 5],
borFieEmu.TSoi[2, 6],
borFieEmu.TSoi[3, 6],
borFieEmu.TSoi[4, 6],
borFieEmu.TSoi[5, 6],
borFieEmu.TSoi[6, 6],
borFieEmu.TSoi[7, 6],
borFieEmu.TSoi[8, 6],
borFieEmu.TSoi[9, 6],
borFieEmu.TSoi[10, 6],
borFieEmu.TSoi[11, 6],
borFieEmu.TSoi[2, 7],
borFieEmu.TSoi[3, 7],
borFieEmu.TSoi[4, 7],
borFieEmu.TSoi[5, 7],
borFieEmu.TSoi[6, 7],
borFieEmu.TSoi[7, 7],
borFieEmu.TSoi[8, 7],
borFieEmu.TSoi[9, 7],
borFieEmu.TSoi[10, 7],
borFieEmu.TSoi[11, 7],
borFieEmu.TSoi[2, 8],
borFieEmu.TSoi[3, 8],
borFieEmu.TSoi[4, 8],
borFieEmu.TSoi[5, 8],
borFieEmu.TSoi[6, 8],
borFieEmu.TSoi[7, 8],
borFieEmu.TSoi[8, 8],
borFieEmu.TSoi[9, 8],
borFieEmu.TSoi[10, 8],
borFieEmu.TSoi[11, 8],
borFieEmu.TSoi[2, 9],
borFieEmu.TSoi[3, 9],
borFieEmu.TSoi[4, 9],
borFieEmu.TSoi[5, 9],
borFieEmu.TSoi[6, 9],
borFieEmu.TSoi[7, 9],
borFieEmu.TSoi[8, 9],
borFieEmu.TSoi[9, 9],
borFieEmu.TSoi[10, 9],
borFieEmu.TSoi[11, 9],
borFieEmu.TSoi[2, 10],
borFieEmu.TSoi[3, 10],
borFieEmu.TSoi[4, 10],
borFieEmu.TSoi[5, 10],
borFieEmu.TSoi[6, 10],
borFieEmu.TSoi[7, 10],
borFieEmu.TSoi[8, 10],
borFieEmu.TSoi[9, 10],
borFieEmu.TSoi[10, 10],
borFieEmu.TSoi[11, 10],
borFieEmu.TSoi[12, 1],
borFieEmu.TSoi[12, 2],
borFieEmu.TSoi[12, 3],
borFieEmu.TSoi[12, 4],
borFieEmu.TSoi[12, 5],
borFieEmu.TSoi[12, 6],
borFieEmu.TSoi[12, 7],
borFieEmu.TSoi[12, 8],
borFieEmu.TSoi[12, 9],
borFieEmu.TSoi[12, 10],
borFieEmu.borHol.intHex[1].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[1].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[1].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[1].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[2].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[2].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[2].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[2].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[3].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[3].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[3].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[3].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[4].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[4].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[4].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[4].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[5].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[5].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[5].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[5].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[6].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[6].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[6].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[6].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[7].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[7].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[7].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[7].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[8].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[8].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[8].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[8].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[9].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[9].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[9].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[9].intRes2UTub.capFil4.T,
borFieEmu.borHol.intHex[10].intRes2UTub.capFil1.T,
borFieEmu.borHol.intHex[10].intRes2UTub.capFil2.T,
borFieEmu.borHol.intHex[10].intRes2UTub.capFil3.T,
borFieEmu.borHol.intHex[10].intRes2UTub.capFil4.T};

    NL_states = {borFieNLC.borHol.intHex[1].vol1.T,borFieNLC.borHol.intHex[1].vol2.T,
    borFieNLC.borHol.intHex[1].vol3.T,borFieNLC.borHol.intHex[1].vol4.T,
    borFieNLC.borHol.intHex[2].vol1.T,borFieNLC.borHol.intHex[2].vol2.T,
    borFieNLC.borHol.intHex[2].vol3.T,borFieNLC.borHol.intHex[2].vol4.T,
    borFieNLC.borHol.intHex[3].vol1.T,borFieNLC.borHol.intHex[3].vol2.T,
    borFieNLC.borHol.intHex[3].vol3.T,borFieNLC.borHol.intHex[3].vol4.T,
    borFieNLC.borHol.intHex[4].vol1.T,borFieNLC.borHol.intHex[4].vol2.T,
    borFieNLC.borHol.intHex[4].vol3.T,borFieNLC.borHol.intHex[4].vol4.T,
    borFieNLC.borHol.intHex[5].vol1.T,borFieNLC.borHol.intHex[5].vol2.T,
    borFieNLC.borHol.intHex[5].vol3.T,borFieNLC.borHol.intHex[5].vol4.T,
    borFieNLC.borHol.intHex[6].vol1.T,borFieNLC.borHol.intHex[6].vol2.T,
    borFieNLC.borHol.intHex[6].vol3.T,borFieNLC.borHol.intHex[6].vol4.T,
    borFieNLC.borHol.intHex[7].vol1.T,borFieNLC.borHol.intHex[7].vol2.T,
    borFieNLC.borHol.intHex[7].vol3.T,borFieNLC.borHol.intHex[7].vol4.T,
    borFieNLC.borHol.intHex[8].vol1.T,borFieNLC.borHol.intHex[8].vol2.T,
    borFieNLC.borHol.intHex[8].vol3.T,borFieNLC.borHol.intHex[8].vol4.T,
    borFieNLC.borHol.intHex[9].vol1.T,borFieNLC.borHol.intHex[9].vol2.T,
    borFieNLC.borHol.intHex[9].vol3.T,borFieNLC.borHol.intHex[9].vol4.T,
    borFieNLC.borHol.intHex[10].vol1.T,borFieNLC.borHol.intHex[10].vol2.T,
    borFieNLC.borHol.intHex[10].vol3.T,borFieNLC.borHol.intHex[10].vol4.T,
    borFieNLC.lay[1].T[1],borFieNLC.lay[1].T[2],borFieNLC.lay[1].T[3],borFieNLC.lay[
    1].T[4],borFieNLC.lay[1].T[5],borFieNLC.lay[1].T[6],borFieNLC.lay[1].T[7],
    borFieNLC.lay[1].T[8],borFieNLC.lay[1].T[9],borFieNLC.lay[1].T[10],
    borFieNLC.lay[2].T[1],borFieNLC.lay[2].T[2],borFieNLC.lay[2].T[3],borFieNLC.lay[
    2].T[4],borFieNLC.lay[2].T[5],borFieNLC.lay[2].T[6],borFieNLC.lay[2].T[7],
    borFieNLC.lay[2].T[8],borFieNLC.lay[2].T[9],borFieNLC.lay[2].T[10],
    borFieNLC.lay[3].T[1],borFieNLC.lay[3].T[2],borFieNLC.lay[3].T[3],borFieNLC.lay[
    3].T[4],borFieNLC.lay[3].T[5],borFieNLC.lay[3].T[6],borFieNLC.lay[3].T[7],
    borFieNLC.lay[3].T[8],borFieNLC.lay[3].T[9],borFieNLC.lay[3].T[10],
    borFieNLC.lay[4].T[1],borFieNLC.lay[4].T[2],borFieNLC.lay[4].T[3],borFieNLC.lay[
    4].T[4],borFieNLC.lay[4].T[5],borFieNLC.lay[4].T[6],borFieNLC.lay[4].T[7],
    borFieNLC.lay[4].T[8],borFieNLC.lay[4].T[9],borFieNLC.lay[4].T[10],
    borFieNLC.lay[5].T[1],borFieNLC.lay[5].T[2],borFieNLC.lay[5].T[3],borFieNLC.lay[
    5].T[4],borFieNLC.lay[5].T[5],borFieNLC.lay[5].T[6],borFieNLC.lay[5].T[7],
    borFieNLC.lay[5].T[8],borFieNLC.lay[5].T[9],borFieNLC.lay[5].T[10],
    borFieNLC.lay[6].T[1],borFieNLC.lay[6].T[2],borFieNLC.lay[6].T[3],borFieNLC.lay[
    6].T[4],borFieNLC.lay[6].T[5],borFieNLC.lay[6].T[6],borFieNLC.lay[6].T[7],
    borFieNLC.lay[6].T[8],borFieNLC.lay[6].T[9],borFieNLC.lay[6].T[10],
    borFieNLC.lay[7].T[1],borFieNLC.lay[7].T[2],borFieNLC.lay[7].T[3],borFieNLC.lay[
    7].T[4],borFieNLC.lay[7].T[5],borFieNLC.lay[7].T[6],borFieNLC.lay[7].T[7],
    borFieNLC.lay[7].T[8],borFieNLC.lay[7].T[9],borFieNLC.lay[7].T[10],
    borFieNLC.lay[8].T[1],borFieNLC.lay[8].T[2],borFieNLC.lay[8].T[3],borFieNLC.lay[
    8].T[4],borFieNLC.lay[8].T[5],borFieNLC.lay[8].T[6],borFieNLC.lay[8].T[7],
    borFieNLC.lay[8].T[8],borFieNLC.lay[8].T[9],borFieNLC.lay[8].T[10],
    borFieNLC.lay[9].T[1],borFieNLC.lay[9].T[2],borFieNLC.lay[9].T[3],borFieNLC.lay[
    9].T[4],borFieNLC.lay[9].T[5],borFieNLC.lay[9].T[6],borFieNLC.lay[9].T[7],
    borFieNLC.lay[9].T[8],borFieNLC.lay[9].T[9],borFieNLC.lay[9].T[10],
    borFieNLC.lay[10].T[1],borFieNLC.lay[10].T[2],borFieNLC.lay[10].T[3],
    borFieNLC.lay[10].T[4],borFieNLC.lay[10].T[5],borFieNLC.lay[10].T[6],
    borFieNLC.lay[10].T[7],borFieNLC.lay[10].T[8],borFieNLC.lay[10].T[9],
    borFieNLC.lay[10].T[10],borFieNLC.Cground[1].T,borFieNLC.Cground[2].T,
    borFieNLC.Cground[3].T,borFieNLC.Cground[4].T,borFieNLC.Cground[5].T,
    borFieNLC.Cground[6].T,borFieNLC.Cground[7].T,borFieNLC.Cground[8].T,
    borFieNLC.Cground[9].T,borFieNLC.Cground[10].T,borFieNLC.borHol.intHex[1].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[1].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[1].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[1].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[2].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[2].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[2].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[2].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[3].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[3].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[3].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[3].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[4].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[4].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[4].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[4].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[5].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[5].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[5].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[5].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[6].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[6].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[6].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[6].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[7].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[7].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[7].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[7].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[8].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[8].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[8].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[8].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[9].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[9].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[9].intRes2UTub.capFil3.T,
    borFieNLC.borHol.intHex[9].intRes2UTub.capFil4.T,borFieNLC.borHol.intHex[10].intRes2UTub.capFil1.T,
    borFieNLC.borHol.intHex[10].intRes2UTub.capFil2.T,borFieNLC.borHol.intHex[
    10].intRes2UTub.capFil3.T,borFieNLC.borHol.intHex[10].intRes2UTub.capFil4.T};

  connect(borFieSSM.y[1], err.u1) annotation (Line(points={{1,70},{30,70},{30,
          36},{38,36}}, color={0,0,127}));
  connect(err.y, error)
    annotation (Line(points={{61,30},{110,30}}, color={0,0,127}));
  connect(TInNLC.port_b, borFieNLC.port_a)
    annotation (Line(points={{-40,-20},{-30,-20}}, color={0,127,255}));
  connect(borFieNLC.port_b, TOutNLC.port_a)
    annotation (Line(points={{10,-20},{20,-20}}, color={0,127,255}));
  connect(TOutNLC.port_b, mFlowNLC.port_a)
    annotation (Line(points={{40,-20},{50,-20}}, color={0,127,255}));
  connect(mFlowNLC.port_b, sink.ports[1])
    annotation (Line(points={{70,-20},{80,-20}}, color={0,127,255}));
  connect(sou.ports[1], TInNLC.port_a)
    annotation (Line(points={{-70,-20},{-60,-20}}, color={0,127,255}));
  connect(realExpression2.y, err.u2)
    annotation (Line(points={{25,24},{38,24}}, color={0,0,127}));
  connect(combiTable2D.y[2],add. u1) annotation (Line(points={{-87,68},{-82,68},
          {-82,76},{-58,76}},
                        color={0,0,127}));
  connect(modTim.y, combiTable2D.u)
    annotation (Line(points={{-129,68},{-110,68}}, color={0,0,127}));
  connect(cToK.y, add.u2) annotation (Line(points={{-63.4,52},{-62,52},{-62,64},
          {-58,64}}, color={0,0,127}));
  connect(add.y, borFieSSM.u[1])
    annotation (Line(points={{-35,70},{-22,70}}, color={0,0,127}));
  connect(add.y, sou.T_in) annotation (Line(points={{-35,70},{-30,70},{-30,38},{
          -96,38},{-96,-16},{-92,-16}}, color={0,0,127}));
  connect(cToK1.y, mFlowNLC.m_flow_in) annotation (Line(points={{-5.4,24},{0,24},
          {0,4},{54,4},{54,-12},{54,-12}}, color={0,0,127}));
  connect(combiTable2D.y[3], cToK1.u) annotation (Line(points={{-87,68},{-84,68},
          {-84,18},{-19.2,18},{-19.2,24}}, color={0,0,127}));
  connect(sou.T_in, sou1.T_in) annotation (Line(points={{-92,-16},{-96,-16},{-96,
          -76},{-92,-76}}, color={0,0,127}));
  connect(sou1.ports[1], TInEmu.port_a)
    annotation (Line(points={{-70,-80},{-60,-80}}, color={0,127,255}));
  connect(TInEmu.port_b, borFieEmu.port_a)
    annotation (Line(points={{-40,-80},{-30,-80}}, color={0,127,255}));
  connect(borFieEmu.port_b, TOutEmu.port_a)
    annotation (Line(points={{10,-80},{20,-80}}, color={0,127,255}));
  connect(TOutEmu.port_b, mFlowEmu.port_a)
    annotation (Line(points={{40,-80},{50,-80}}, color={0,127,255}));
  connect(mFlowEmu.port_b, sink1.ports[1])
    annotation (Line(points={{70,-80},{80,-80}}, color={0,127,255}));
  connect(mFlowNLC.m_flow_in, mFlowEmu.m_flow_in) annotation (Line(points={{54,
          -12},{54,-4},{44,-4},{44,-56},{54,-56},{54,-72}}, color={0,0,127}));
  connect(combiTable2D.y[6], convFacCal.u) annotation (Line(points={{-87,68},{
          -86,68},{-86,90},{-168,90},{-168,-190},{-46,-190}}, color={0,0,127}));
  connect(convFacCal.y, integrator3.u)
    annotation (Line(points={{-23,-190},{-2,-190}}, color={0,0,127}));
  connect(integrator3.y, QCal)
    annotation (Line(points={{21,-190},{110,-190}}, color={0,0,127}));
  connect(Qbor.y, integrator1.u)
    annotation (Line(points={{-19,-150},{-2,-150}}, color={0,0,127}));
  connect(integrator1.y, QBor) annotation (Line(points={{21,-150},{66,-150},{66,
          -160},{110,-160}}, color={0,0,127}));
  connect(Qmea.y, integrator2.u)
    annotation (Line(points={{-19,-170},{-2,-170}}, color={0,0,127}));
  connect(integrator2.y, QMea) annotation (Line(points={{21,-170},{62,-170},{62,
          -176},{110,-176}}, color={0,0,127}));
  connect(QborAbs.y, integrator5.u)
    annotation (Line(points={{-19,-110},{-2,-110}}, color={0,0,127}));
  connect(integrator5.y, QBorAbs) annotation (Line(points={{21,-110},{62,-110},
          {62,-116},{110,-116}}, color={0,0,127}));
  connect(QmeaAbs.y, integrator4.u)
    annotation (Line(points={{-19,-130},{-2,-130}}, color={0,0,127}));
  connect(integrator4.y, QMeaAbs) annotation (Line(points={{21,-130},{64,-130},
          {64,-132},{110,-132}}, color={0,0,127}));
  connect(realExpression4.y, lin_xe)
    annotation (Line(points={{71,62},{110,62}}, color={0,0,127}));
  connect(realExpression3.y, NL_xe)
    annotation (Line(points={{71,84},{110,84}}, color={0,0,127}));
  annotation (
    experiment(
      StartTime=480,
      StopTime=17365920,
      Interval=480,
      Tolerance=1e-06,
      __Dymola_fixedstepsize=5,
      __Dymola_Algorithm="Euler"),
    __Dymola_experimentSetupOutput(events=false),
    __Dymola_experimentFlags(
      Advanced(
        EvaluateAlsoTop=false,
        GenerateVariableDependencies=false,
        OutputModelicaCode=false,
        InlineMethod=0,
        InlineOrder=2,
        InlineFixedStep=0.001),
      Evaluate=true,
      OutputCPUtime=true,
      OutputFlatModelica=false),
    Diagram(coordinateSystem(extent={{-100,-200},{100,100}})),
    Icon(coordinateSystem(extent={{-100,-200},{100,100}})));
end InfraxValidation;
