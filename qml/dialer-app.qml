/*
 * Copyright 2012-2016 Canonical Ltd.
 *
 * This file is part of dialer-app.
 *
 * dialer-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * dialer-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Qt.labs.settings 1.0

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import ServiceControl 1.0
import Linphone 1.0

MainView {
    id: mainView

    objectName: "mainView"
    applicationName: "linphone.cibersheep"

    property bool applicationActive: Qt.application.active
    property string ussdResponseTitle: ""
    property string ussdResponseText: ""
    property bool greeterMode: (state == "greeterMode")
    property bool telepathyReady: false
    property var currentStack: mainView.greeterMode ? pageStackGreeterMode : pageStackNormalMode
    property var bottomEdge: null

    //automaticOrientation: false
    implicitWidth: units.gu(40)
    implicitHeight: units.gu(71)

    //property bool hasCalls: callManager.hasCalls

    signal applicationReady
    signal closeUSSDProgressDialog

    property string pendingNumberToDial: ""
    property bool accountReady: false

    Settings {
        id: dualSimSettings
        category: "DualSim"
        property bool dialPadDontAsk: false
        property int mainViewDontAskCount: 0
    }

    Settings {
        id: generalSettings
        property string lastCalledPhoneNumber: ""
    }

    ServiceControl {
        id: serviceControl
        appId: 'linphone.cibersheep'
        serviceName: 'linphone'

        //TODO don't hardcode these
        servicePath: '/opt/click.ubuntu.com/linphone.cibersheep/current/linphone/bin/linphonec --pipe'
        libraryPath: '/opt/click.ubuntu.com/linphone.cibersheep/current/linphone/lib/arm-linux-gnueabihf'
        extraEnv: 'env TMPDIR=/home/phablet/.cache/linphone-tmp/'
        preStartScript: 'mkdir -p $TMPDIR'

        Component.onCompleted: {
            if (!serviceFileInstalled) {
                console.log('Service file not installed, installing now')
                installServiceFile();
            }

            // TODO if we have just installed a new version of the app there should be a manditory restart of linphone
            Linphone.setConfig('ubuntu_touch/exec_incoming_call', 'bash /opt/click.ubuntu.com/linphone.cibersheep/current/linphone/incoming-call.sh');

            // TODO make these configurable
            // ogg isn't supported so we can't use the system ringtones
            Linphone.setConfig('sound/remote_ring', '/opt/click.ubuntu.com/linphone.cibersheep/current/ringtones/ringback.wav')
            Linphone.setConfig('sound/local_ring', '/opt/click.ubuntu.com/linphone.cibersheep/current/ringtones/Ubuntu.wav')

            if (!serviceRunning) {
                console.log('Service not running, starting now')
                startService();
            }
        }
    }

	
    state: "normalMode"
    states: [
        State {
            name: "greeterMode"

            StateChangeScript {
                script: {
                    // preload greeter stack if not done yet
                    if (pageStackGreeterMode.depth == 0) {
                        //pageStackGreeterMode.push(Qt.resolvedUrl("DialerPage.qml"))
                        pageStackGreeterMode.push(Qt.resolvedUrl("Totest.qml"))
                    }
                    // make sure to reset the view so that the contacts page is not loaded

                }
            }
        },
        State {
            name: "normalMode"

            StateChangeScript {
                script: {
                    // make sure to reset the view so that the contacts page is not loaded

                }
            }
        }
    ]

    function isEmergencyNumber(number) {
        console.log("isEmergencyNumber called")
        return false;
    }

    function addNewPhone(phoneNumber)
    {
        pageStackNormalMode.push(Qt.resolvedUrl("ContactsPage/ContactsPage.qml"),
                                 {"phoneToAdd": phoneNumber})
    }

    function viewContact(contact, contactListPage, model) {
        var initialPropers = {}
        if (model)
            initialPropers["model"]  = model

        if (typeof(contact) == 'string') {
            initialPropers["contactId"] = contact
        } else {
            initialPropers["contact"] = contact
        }
        pageStackNormalMode.push(Qt.resolvedUrl("ContactViewPage/DialerContactViewPage.qml"),
                                 initialPropers)
    }

    function addPhoneToContact(contact, phoneNumber, contactListPage, model) {
        var initialPropers =  {}

        if (phoneNumber)
            initialPropers["addPhoneToContact"] = phoneNumber

        if (contactListPage)
            initialPropers["contactListPage"] = contactListPage

        if (model)
            initialPropers["model"] = model

        if (typeof(contact) == 'string') {
            initialPropers["contactId"] = contact
        } else {
            initialPropers["contact"] = contact
        }

        pageStackNormalMode.push(Qt.resolvedUrl("ContactViewPage/DialerContactViewPage.qml"),
                                 initialPropers)
    }

    function sendMessage(phoneNumber) {
        Qt.openUrlExternally("message:///" + encodeURIComponent(phoneNumber))
    }

    function callVoicemail() {
        if (mainView.greeterMode) {
            return;
        }
        call(mainView.account.voicemailNumber);
    }

    function checkUSSD(number) {
        var endString = "#"
        // check if it ends with #
        if (number.slice(-endString.length) == endString) {
            // check if it starts with any of these strings
            var startStrings = ["*", "#", "**", "##", "*#"]
            for(var i in startStrings) {
                if (number.slice(0, startStrings[i].length) == startStrings[i]) {
                    return true
                }
            }
        }
        return false
    }

    function checkMMI(number) {
        var endString1 = "#"
        var endString2 = "*"
        // check if it ends with # or *
        if (number.slice(-endString1.length) == endString1 || number.slice(-endString2.length) == endString2) {
            // check if it starts with any of these strings
            var startStrings = ["*", "#", "**", "##", "*#"]
            for(var i in startStrings) {
                if (number.slice(0, startStrings[i].length) == startStrings[i]) {
                    return true
                }
            }
        }
        return false
    }

    function callEmergency(number) {
        // if we are in flight mode, we first need to disable it and wait for
        // the modems to update


        animateLiveCall();

        var account = null;
        // check if the selected account is active and can make emergency calls
        if (mainView.account && mainView.account.active && mainView.account.emergencyCallsAvailable) {
            account = mainView.account
        } else if (accountsModel.activeAccounts.length > 0) {
            // now try to use one of the connected accounts
            account = accountsModel.activeAccounts[0];
        } else {
            // if no account is active, use any account that can make emergency calls

        }

        // not sure what to do when no accounts can make emergency calls
        if (account == null) {
            pendingNumberToDial = number;
            return;
        }

        if (!accountReady) {
            pendingNumberToDial = number;
            return;
        }

        console.log("place a call: " + number);
    }

    function call(number, skipDefaultSimDialog) {
        // clear the values here so that the changed signals are fired when the new value is set
        pendingNumberToDial = "";

        if (number === "") {
            return
        }

        if (isEmergencyNumber(number)) {
            callEmergency(number);
            return;
        }



        // check if at least one account is selected
        if (multiplePhoneAccounts && !mainView.account) {
            Qt.inputMethod.hide()
            showNotification(i18n.tr("No SIM card selected"), i18n.tr("You need to select a SIM card"));
            return
        }

        if (multiplePhoneAccounts && !telepathyHelper.defaultCallAccount && !dualSimSettings.dialPadDontAsk && !skipDefaultSimDialog) {
            var properties = {}
            properties["phoneNumber"] = number
            properties["accountId"] = mainView.account.accountId
            PopupUtils.open(Qt.createComponent("Dialogs/SetDefaultSIMCardDialog.qml").createObject(mainView), mainView, properties)
            return
        }

        if (mainView.account && !mainView.greeterMode && mainView.account.simLocked) {
            showSimLockedDialog();
            return
        }

        // avoid cleaning the keypadEntry in case there is no signal
        if (!mainView.account) {
            showNotification(i18n.tr("No network"), i18n.tr("There is currently no network."))
            return
        }

        if (!mainView.account.connected) {
            showNotification(i18n.tr("No network"),
                             telepathyHelper.voiceAccounts.displayed.length >= 2 ? i18n.tr("There is currently no network on %1").arg(mainView.account.displayName)
                                                                    : i18n.tr("There is currently no network."))
            return
        }

        if (checkUSSD(number)) {
            PopupUtils.open(Qt.resolvedUrl("Dialogs/UssdProgressDialog.qml"), mainView)
            account.ussdManager.initiate(number)
            return
        }

        animateLiveCall();

        if (!accountReady) {
            pendingNumberToDial = number;
            return;
        }

        if (account && account.connected) {
            generalSettings.lastCalledPhoneNumber = number
            console.log("Start a call: " +number);
        }
    }

    function populateDialpad(number, accountId) {
        // populate the dialpad with the given number but don't start the call
        // FIXME: check what to do when not in the dialpad view

        // if not on the livecall view, go back to the dialpad
        while (pageStackNormalMode.depth > 1) {
            pageStackNormalMode.pop();
        }

        var dialerPage = pageStackNormalMode.currentPage
        if (dialerPage && typeof(dialerPage.dialNumber) != 'undefined') {
            dialerPage.dialNumber = number;
            if (accountId) {
                dialerPage.selectAccount(accountId)
            }

            if (dialerPage.bottomEdgeItem) {
                dialerPage.bottomEdgeItem.collapse()
            }
        }
    }

    function removeLiveCallView() {
        // if on contacts page in a live call and no calls are found, pop it out
        if (pageStackNormalMode.depth > 2 && pageStackNormalMode.currentPage.objectName == "contactsPage") {
            pageStackNormalMode.pop();
        }

        if (pageStackNormalMode.depth > 1 && pageStackNormalMode.currentPage.objectName == "pageLiveCall") {
            pageStackNormalMode.pop();
        }

        while (pageStackGreeterMode.depth > 1) {
            pageStackGreeterMode.pop();
        }
    }

    function switchToKeypadView() {
        while (pageStackNormalMode.depth > 1) {
            pageStackNormalMode.pop();
        }
        while (pageStackGreeterMode.depth > 1) {
            pageStackGreeterMode.pop();
        }
    }

    function animateLiveCall() {
        if (currentStack.currentPage && currentStack.currentPage.triggerCallAnimation) {
            currentStack.currentPage.triggerCallAnimation();
        } else {
            switchToLiveCall();
        }
    }

    function switchToLiveCall(initialStatus, initialNumber) {
        if (pageStackNormalMode.depth > 2 && pageStackNormalMode.currentPage.objectName == "contactsPage") {
            // pop contacts Page
            pageStackNormalMode.pop();
        }

        var properties = {}
        properties["initialStatus"] = initialStatus
        properties["initialNumber"] = initialNumber
        if (isEmergencyNumber(pendingNumberToDial)) {
            properties["defaultTimeout"] = 30000
        }

        if (currentStack.currentPage.objectName == "pageLiveCall") {
            return;
        }

        currentStack.push(Qt.resolvedUrl("LiveCallPage/LiveCall.qml"), properties)
    }

    function showNotification(title, text) {
        PopupUtils.open(Qt.resolvedUrl("Dialogs/NotificationDialog.qml"), mainView, {title: title, text: text});
    }

    function showSimLockedDialog() {
        var properties = {}
        properties["accountId"] = mainView.account.accountId
        PopupUtils.open(Qt.createComponent("Dialogs/SimLockedDialog.qml").createObject(mainView), mainView, properties)
    }

    function accountForModem(modemName) {
        var modemAccounts = telepathyHelper.phoneAccounts.displayed
        for (var i in modemAccounts) {
            if (modemAccounts[i].modemName == modemName) {
                return modemAccounts[i]
            }
        }
        return null
    }


    Connections {
        target: UriHandler
        onOpened: {
           /*for (var i = 0; i < uris.length; ++i) {
               application.parseArgument(uris[i])
           }
           */
           console.log("Opened UriHandler form dialer-app.qml")
       }
    }

    Component.onCompleted: {
        i18n.domain = "dialer-app"
        /*
        i18n.bindtextdomain("dialer-app", i18nDirectory)
        */
        //pageStackNormalMode.push(Qt.createComponent("DialerPage.qml"))
        pageStackNormalMode.push(Qt.createComponent("Totest.qml"))

        // when running in windowed mode, do not allow resizing
        //view.minimumWidth  = units.gu(40)
        //view.minimumHeight = units.gu(52)

        // if there are calls, even if we don't have info about them yet, push the livecall view
        /*
        if (callManager.hasCalls) {
            switchToLiveCall();
        }
        */

        //For Testing: Linphone.call("sip:username@ip:5060");
    }




    PageStack {
        id: pageStackNormalMode
        anchors.fill: parent
        active:  mainView.state == "normalMode"
        visible: active
    }

    PageStack {
        id: pageStackGreeterMode
        anchors.fill: parent
        active: mainView.state == "greeterMode"
        visible: active
    }
}
