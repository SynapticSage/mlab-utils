function levels = datatypeLevels(datatype)

levels = [];
switch char(datatype)
case 'cellinfo_table'
    levels = [];
case {'DIO','dio','task','diotable','event','traj','events','events', 'cellinfo_table', 'behavior', 'egocentric'}
    levels = ["day","epoch"];
case {'eeg','eegref','delta','theta','beta','gamma','ripple'}
    levels = ["day","epoch","tetrode"];
case {'avgeeg','avgeegref','avgdelta','avgtheta','avgbeta','avggamma','avgripple'}
    levels = ["day","epoch","area"]; % area as in brain area
case {'spikes','cellinfo','marks'}
    levels = ["day","epoch","tetrode","cell"];
case {'cgramc','cgramcnew'}
    levels = ["day","epoch","tetrodeX","tetrodeY"];
otherwise
    warning('Datatype level not found')
end
