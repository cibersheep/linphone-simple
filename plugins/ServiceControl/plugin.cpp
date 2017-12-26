#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "servicecontrol.h"

void LinphonePlugin::registerTypes(const char *uri) {
    //@uri ServiceControl
    qmlRegisterType<ServiceControl>(uri, 1, 0, "ServiceControl");
}
