#ifndef SERVICECONTROLPLUGIN_H
#define SERVICECONTROLPLUGIN_H

#include <QQmlExtensionPlugin>

class LinphonePlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif
