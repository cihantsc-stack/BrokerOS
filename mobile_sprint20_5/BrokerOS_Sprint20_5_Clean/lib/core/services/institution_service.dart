import '../models/institution_flow.dart';

class InstitutionService {
  static List<InstitutionFlow> today() {
    return const [
      InstitutionFlow(
        institution: 'İş Yatırım',
        buy: 31.4,
        sell: 6.6,
        net: 24.8,
      ),
      InstitutionFlow(
        institution: 'Bank of America',
        buy: 26.7,
        sell: 8.5,
        net: 18.2,
      ),
      InstitutionFlow(
        institution: 'Yapı Kredi',
        buy: 22.1,
        sell: 7.6,
        net: 14.5,
      ),
      InstitutionFlow(
        institution: 'Ak Yatırım',
        buy: 7.3,
        sell: 16.4,
        net: -9.1,
      ),
    ];
  }
}