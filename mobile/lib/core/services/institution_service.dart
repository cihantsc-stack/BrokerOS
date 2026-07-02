import '../models/institution_flow.dart';

class InstitutionService{

  static List<InstitutionFlow> today(){

    return const [

      InstitutionFlow(

        institution:"İş Yatırım",

        amount:24.8,

        buy:true,

      ),

      InstitutionFlow(

        institution:"Bank of America",

        amount:18.2,

        buy:true,

      ),

      InstitutionFlow(

        institution:"Yapı Kredi",

        amount:14.5,

        buy:true,

      ),

      InstitutionFlow(

        institution:"Ak Yatırım",

        amount:9.1,

        buy:false,

      ),

    ];

  }

}