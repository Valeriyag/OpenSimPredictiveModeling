function vectOut = arm26_AddOutValues(osimModel,osimState)

import org.opensim.modeling.*;

vectOut(1,1)=osimModel.getJointSet().get('r_elbow').getCoordinateSet().get('r_elbow_flex').getValue(osimState);
vectOut(1,2)=osimModel.getJointSet().get('r_shoulder').getCoordinateSet().get('r_shoulder_elev').getValue(osimState);


