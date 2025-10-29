import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../../../../routing/routes.dart';
import '../../../../config/presentation/app_palette.dart';
import '../../../../config/presentation/layout_config.dart';
import '../../../../shared/presentation/components/button.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/components/widget_decoration.dart';
import '../../../../shared/presentation/dialogs/dialogs.dart'
    show generalDialog, simpleDialog, DialogType;
import '../../../../shared/presentation/form_elements/text_field.dart';
import '../../../../shared/presentation/widgets/profile_indicator.dart';
import '../../authentication.dart' show AuthenticationRepository;
import '../../domain/add_contact_form.dart';
import 'account_form.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: WhiteSpace.zero,
      child: Column(
        children: [
          const AccountFormCard(),
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Email Addresses",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppPalette.black),
                  ),
                  WhiteSpace.b6,
                  Text(
                    "You can use the following email addresses to sign in to your account and also to reset your password if you ever forget it.",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: AppPalette.greyS8),
                  ),
                  WhiteSpace.b16,
                  ...AuthenticationRepository().currentUser.emails.map(
                        (email) => ContactTile(
                          isEmail: true,
                          isPrimary:
                              AuthenticationRepository().currentUser.email ==
                                  email,
                          title: email,
                        ),
                      ),
                  WhiteSpace.b32,
                  Center(
                    child: Button(
                      onPressed: () {
                        _addContact(context, true);
                      },
                      backgroundColor: null,
                      toolTip: "Add Email Address",
                      child: Text(
                        '+ Add Email Address',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: AppPalette.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: AppPalette.white,
            shape: WidgetDecoration.roundedEdge5,
            margin: WhiteSpace.all10,
            child: Padding(
              padding: WhiteSpace.all20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Mobile Numbers",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppPalette.black),
                  ),
                  WhiteSpace.b6,
                  Text(
                    "View and manage all of the mobile numbers associated with your account.",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: AppPalette.greyS8),
                  ),
                  WhiteSpace.b16,
                  ...AuthenticationRepository().currentUser.phoneNumbers.map(
                        (number) => ContactTile(
                          isEmail: false,
                          isPrimary: AuthenticationRepository()
                                  .currentUser
                                  .contact
                                  .toString() ==
                              number,
                          title: "+91-$number",
                        ),
                      ),
                  WhiteSpace.b32,
                  Center(
                    child: Button(
                      onPressed: () {
                        //_addContact(context, false);
                      },
                      backgroundColor: null,
                      toolTip: "Add Mobile Number",
                      child: Text(
                        '+ Add Mobile Number',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: AppPalette.greyC3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _addContact(BuildContext context, bool isEmailContact) {
    generalDialog(context,
        barrierDismissible: true,
        alignment: Alignment.center,
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox(
            height: LayoutConfig().setFractionHeight(40),
            width: LayoutConfig().setFractionWidth(40),
            child: BlocProvider(
              create: (BuildContext context) => AddContactFormBloc(),
              child: Builder(
                builder: (BuildContext context) {
                  final contactForm =
                      BlocProvider.of<AddContactFormBloc>(context);
                  contactForm.isEmailContact = isEmailContact;

                  return FormBlocListener<AddContactFormBloc, String, String>(
                    onSubmitting: (context, state) {},
                    onSuccess: (context, state) {
                      context.rootPop();
                    },
                    onFailure: (context, state) {
                      context.rootPop();
                      final response = jsonDecode(state.failureResponse!);
                      simpleDialog(context,
                          type: DialogType.error,
                          title: response['title'],
                          content: response['content'],
                          buttonName: "Close");
                    },
                    child: Column(
                      children: [
                        WhiteSpace.b32,
                        Text(
                          isEmailContact
                              ? "Add Email Address"
                              : "Add Mobile Numbers",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: AppPalette.white,
                                  fontWeight: FontWeight.bold),
                        ),
                        WhiteSpace.b12,
                        Padding(
                          padding: WhiteSpace.h30,
                          child: Text(
                            "An activation link will be sent to your ${isEmailContact ? 'email address' : 'mobile number'} for verification",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: AppPalette.white),
                          ),
                        ),
                        WhiteSpace.b16,
                        Padding(
                          padding: WhiteSpace.h30,
                          child: FormTextField(
                            textFieldBloc: contactForm.contact,
                            label: isEmailContact
                                ? "Email address"
                                : "Mobile number",
                            icon: isEmailContact
                                ? Icons.email_outlined
                                : Icons.call_outlined,
                            isPasswordField: false,
                          ),
                        ),
                        WhiteSpace.spacer,
                        const Divider(thickness: 0.2, color: AppPalette.greyS8),
                        WhiteSpace.b16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Button(
                              buttonPadding: WhiteSpace.zero,
                              onPressed: () {
                                context.rootPop();
                              },
                              backgroundColor: AppPalette.transparent,
                              child: Text(
                                "Cancel",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: AppPalette.red,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            WhiteSpace.w32,
                            Button(
                              buttonPadding: WhiteSpace.zero,
                              onPressed: () {
                                contactForm.contact.validate();
                                if (contactForm.state.isValid()) {
                                  contactForm.submit();
                                }
                              },
                              backgroundColor: AppPalette.transparent,
                              child: Text(
                                "Add",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: AppPalette.green,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            WhiteSpace.w32,
                          ],
                        ),
                        WhiteSpace.spacer,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }
}

class AccountFormCard extends StatefulWidget {
  const AccountFormCard({super.key});

  @override
  State<AccountFormCard> createState() => _AccountFormCardState();
}

class _AccountFormCardState extends State<AccountFormCard> {
  bool isEditOn = false;

  @override
  void initState() {
    super.initState();
    isEditOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.white,
      shape: WidgetDecoration.roundedEdge5,
      margin: WhiteSpace.h10,
      child: Padding(
        padding: WhiteSpace.all20,
        child: Column(
          children: [
            WhiteSpace.b12,
            Row(
              children: [
                CircleAvatarWithStatus(
                  size: LayoutConfig().setFractionHeight(10),
                  icon: Icons.person,
                  isOnline: true,
                ),
                WhiteSpace.w32,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AuthenticationRepository().currentUser.getFullName(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppPalette.black),
                    ),
                    WhiteSpace.b6,
                    Text(
                      AuthenticationRepository().currentUser.email,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: AppPalette.black),
                    ),
                    WhiteSpace.b6,
                    Text(
                      'User ID: ${AuthenticationRepository().currentUser.userId}',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: AppPalette.black),
                    ),
                  ],
                ),
                WhiteSpace.spacer,
                if (!isEditOn)
                  Button(
                    onPressed: () {
                      isEditOn = true;
                      setState(() {});
                    },
                    toolTip: "Edit details",
                    child: Text(
                      'Edit',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                WhiteSpace.w96
              ],
            ),
            WhiteSpace.b32,
            WhiteSpace.b12,
            AccountForm(
              isEnabled: isEditOn,
              saveCallback: () {
                isEditOn = false;
                setState(() {});
              },
              cancelCallback: () {
                isEditOn = false;
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final bool isEmail;
  final bool isPrimary;
  final String title;
  const ContactTile({
    super.key,
    required this.isEmail,
    required this.isPrimary,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final size = LayoutConfig().setFractionHeight(10);
    return ListTile(
      onTap: () {},
      contentPadding: WhiteSpace.all10,
      leading: CircleAvatar(
        radius: size / 2,
        backgroundColor: isEmail ? AppPalette.orange : AppPalette.greenS8,
        child: Icon(
          isEmail ? Icons.mail_outline : Icons.phone_outlined,
          size: size * 0.35,
          color: AppPalette.white,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: AppPalette.black),
      ),
      trailing: isPrimary
          ? Tooltip(
              textAlign: TextAlign.justify,
              richMessage: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: isEmail
                          ? 'Primary Email Address\n'
                          : 'Primary Mobile Number\n',
                      style: Theme.of(context).textTheme.labelLarge),
                  TextSpan(
                    text: isEmail
                        ? 'We use your primary email address for all communications with you,\nwhich includes announcements, notifications, and alerts.'
                        : 'We use your primary mobile number for all communications with you,\nwhich includes announcements, notifications, and alerts.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_outlined),
            )
          : null,
    );
  }
}
