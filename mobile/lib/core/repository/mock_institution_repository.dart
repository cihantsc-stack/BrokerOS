import '../models/institution_flow.dart';
import 'institution_repository.dart';

class MockInstitutionRepository
    implements InstitutionRepository {

  @override
  List<InstitutionFlow> getTodayFlows() {
    return const [

      InstitutionFlow(
        institution: "İş Yatırım",
        buy: 862,
        sell: 438,
        net: 424,
      ),

      InstitutionFlow(
        institution: "Ak Yatırım",
        buy: 654,
        sell: 455,
        net: 199,
      ),

      InstitutionFlow(
        institution: "Yapı Kredi",
        buy: 510,
        sell: 353,
        net: 157,
      ),

      InstitutionFlow(
        institution: "Garanti",
        buy: 440,
        sell: 310,
        net: 130,
      ),

      InstitutionFlow(
        institution: "QNB",
        buy: 381,
        sell: 302,
        net: 79,
      ),
    ];
  }
}