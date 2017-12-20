#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "linphone.h"

void LinphonePlugin::registerTypes(const char *uri) {
    //@uri Linphone
    qmlRegisterSingletonType<Linphone>(uri, 1, 0, "Linphone", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Linphone; });
}
