class DerivedParameters {
  int? _pip;
  int? _peep;
  int? _pplat;
  double? _map;
  int? _fio;
  int? _spo;
  int? _pulse;
  int? _vti;
  int? _vte;
  int? _rr;
  double? _i;
  double? _e;
  double? _ti;
  double? _te;
  int? _pif;
  int? _pef;
  double? _rInsp;
  double? _cstat;
  double? _cplat;
  double? _minVol;
  double? _pi;
  int? _ipap;
  int? _epap;

  DerivedParameters();

  String? get pip => _pip?.toString();
  String? get peep => _peep?.toString();
  String? get vti => _vti?.toString();
  String? get vte => _vte?.toString();
  String? get pif => _pif?.toString();
  String? get pef => _pef?.toString();
  String? get rr => _rr?.toString();
  String? get i => _i?.toStringAsFixed(1);
  String? get e => _e?.toStringAsFixed(1);
  String? get ti => _ti?.toStringAsFixed(2);
  String? get te => _te?.toStringAsFixed(2);
  String? get map => _map?.toStringAsFixed(2);
  String? get spo => _spo?.toString();
  String? get pulse => _pulse?.toString();
  String? get pi => _pi?.toStringAsFixed(2);
  String? get cplat => _cleanData(_cplat?.toStringAsFixed(2));
  String? get cstat => _cleanData(_cstat?.toStringAsFixed(2));
  String? get rInsp => _cleanData(_rInsp?.toStringAsFixed(2));
  String? get pplat => _pplat?.toString();
  String? get fio => _fio?.toString();
  String? get ipap => _ipap?.toString();
  String? get epap => _epap?.toString();
  String? get minVol => _minVol?.toStringAsFixed(2);

  int get pipValue => _pip ?? 0;
  int get peepValue => _peep ?? 0;
  int get vtiValue => _vti ?? 0;
  int get vteValue => _vte ?? 0;
  int get pifValue => _pif ?? 0;
  int get pefValue => _pef ?? 0;
  int get rrValue => _rr ?? 0;
  double get iValue => _i ?? 0.0;
  double get eValue => _e ?? 0.0;
  double get tiValue => _ti ?? 0.0;
  double get teValue => _te ?? 0.0;
  double get mapValue => _map ?? 0.0;
  int get spoValue => _spo ?? 0;
  int get pulseValue => _pulse ?? 0;
  double get piValue => _pi ?? 0.0;
  double get cplatValue => _cplat ?? 0.0;
  double get cstatValue => _cstat ?? 0.0;
  double get rInspValue => _rInsp ?? 0.0;
  int get pplatValue => _pplat ?? 0;
  int get fioValue => _fio ?? 0;
  int get ipapValue => _ipap ?? 0;
  int get epapValue => _epap ?? 0;
  double get minVolValue => _minVol ?? 0.0;
  get vitalParameters => {
        'pip': _pip?.toString(),
        'peep': _peep?.toString(),
        'vti': _vti?.toString(),
        'fio': _fio?.toString()
      };

  set pip(newPip) => _pip = newPip;
  set peep(newPeep) => _peep = newPeep;
  set vti(newVti) => _vti = newVti;
  set vte(newVte) => _vte = newVte;
  set pif(newPif) => _pif = newPif;
  set pef(newPef) => _pef = newPef;
  set rr(newRr) => _rr = newRr;
  set i(newI) => _i = newI;
  set e(newE) => _e = newE;
  set ti(newTi) => _ti = newTi;
  set te(newTe) => _te = newTe;
  set spo(newSpo) => _spo = newSpo;
  set pulse(newPulse) => _pulse = newPulse;
  set pi(newPi) => _pi = newPi;
  set pplat(newPPlat) => _pplat = newPPlat;
  set map(newMap) => _map = newMap;
  set fio(newFio) => _fio = newFio;
  set ipap(newIpap) => _ipap = newIpap;
  set epap(newEpap) => _epap = newEpap;
  set minVol(newMinVol) => _minVol = newMinVol;
  set cplat(newCplat) => _cplat = newCplat;
  set cstat(newCstat) => _cstat = newCstat;
  set rInsp(newValue) => _rInsp = newValue;

  _cleanData(data) {
    if (data?.contains('fini') ?? true) {
      return null;
    }
    return data;
  }
}
