import 'package:flutter_test/flutter_test.dart';
import 'package:my_parlor/app/core/constants/flow_type_constants.dart';
import 'package:my_parlor/app/data/models/appointment_model.dart';
import 'package:my_parlor/app/data/models/parlor_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ParlorModel Tests', () {
    test('Default gender should be Female if not provided', () {
      final parlor = ParlorModel(
        id: 'p1',
        parlorName: 'Test Lounge',
        ownerName: 'Owner',
        email: 'test@gmail.com',
        password: 'pass',
        phone: '1234567890',
        address: 'Main Road',
      );
      expect(parlor.gender, 'Female');
    });

    test('Custom gender (Male / Unisex) should serialize and deserialize accurately', () {
      final maleParlor = ParlorModel(
        id: 'p2',
        parlorName: 'Men Salon',
        ownerName: 'Barber',
        email: 'barber@gmail.com',
        password: 'pass',
        phone: '1234567890',
        address: 'Market',
        gender: 'Male',
      );

      final map = maleParlor.toMap();
      expect(map['gender'], 'Male');

      final fromMapParlor = ParlorModel.fromMap(map, docId: 'p2');
      expect(fromMapParlor.gender, 'Male');
      expect(fromMapParlor.parlorName, 'Men Salon');
    });

    test('Old Firestore data without gender field should fallback safely to Female', () {
      final oldData = {
        'id': 'old_1',
        'parlorName': 'Old Salon',
        'ownerName': 'Old Owner',
        'email': 'old@gmail.com',
        'password': 'pass',
        'phone': '1234567890',
        'address': 'Street 1',
        // 'gender' key is missing in old records
      };

      final parlor = ParlorModel.fromMap(oldData, docId: 'old_1');
      expect(parlor.gender, 'Female');
    });
  });

  group('FlowTypeConstants & Permissions Compatibility', () {
    test('Existing flow types should remain 100% functional', () {
      final allowedRights = [
        FlowTypeConstants.walkInOrders,
        FlowTypeConstants.advanceAppointment,
        FlowTypeConstants.bridalOrders,
        FlowTypeConstants.package,
        FlowTypeConstants.homeService,
      ];

      expect(FlowTypeConstants.isAllowed(allowedRights, 'Walk in orders'), isTrue);
      expect(FlowTypeConstants.isAllowed(allowedRights, 'Advance appoinment'), isTrue);
      expect(FlowTypeConstants.isAllowed(allowedRights, 'Package'), isTrue);
      expect(FlowTypeConstants.isAllowed(allowedRights, 'Home service'), isTrue);
    });

    test('Bridal Orders right should seamlessly match Groom Orders for Men salons', () {
      final allowedRights = ['Bridal Orders'];

      // Both bridal and groom variations should be allowed
      expect(FlowTypeConstants.isAllowed(allowedRights, 'Bridal Orders'), isTrue);
      expect(FlowTypeConstants.isAllowed(allowedRights, 'Groom Orders'), isTrue);
      expect(FlowTypeConstants.isAllowed(allowedRights, 'Bridal & Groom Orders'), isTrue);
    });

    test('FlowTypeItem dynamic gender labels and descriptions in Admin', () {
      final bridalItem = FlowTypeConstants.allFlowTypes.firstWhere((e) => e.id == 'bridal_orders');
      expect(bridalItem.getLabelKey('Female'), 'bridal_orders');
      expect(bridalItem.getLabelKey('Male'), 'groom_orders');
      expect(bridalItem.getLabelKey('Unisex'), 'bridal_and_groom_orders');
      expect(bridalItem.getDescription('Male'), contains('groom'));
      expect(bridalItem.getDescription('Female'), contains('bridal'));
    });
  });

  group('AppointmentModel Backward Compatibility', () {
    test('Appointments with or without clientGender should deserialize cleanly', () {
      final appointment = AppointmentModel(
        id: 'app_1',
        clientName: 'Rahul',
        mobileNumber: '9999999999',
        serviceName: 'Haircut',
        category: 'Hair',
        amount: 250,
        status: 'Confirmed',
        bookingDateTime: DateTime.now(),
        visitingDateTime: DateTime.now(),
        clientGender: 'Male',
      );

      final map = appointment.toMap();
      expect(map['clientGender'], 'Male');

      final fromMap = AppointmentModel.fromMap(map, docId: 'app_1');
      expect(fromMap.clientGender, 'Male');
      expect(fromMap.clientName, 'Rahul');
    });
  });
}
