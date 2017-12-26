//Modified from http://bazaar.launchpad.net/~mzanetti/rockwork/trunk/view/head:/rockwork/servicecontrol.h

#ifndef SERVICECONTROL_H
#define SERVICECONTROL_H

#include <QObject>

class ServiceControl : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString serviceName READ serviceName WRITE setServiceName NOTIFY serviceNameChanged)
    Q_PROPERTY(QString appId READ serviceName WRITE setAppId NOTIFY appIdChanged)
    Q_PROPERTY(QString servicePath READ servicePath WRITE setServicePath NOTIFY servicePathChanged)
    Q_PROPERTY(QString libraryPath READ libraryPath WRITE setLibraryPath NOTIFY libraryPathChanged)
    Q_PROPERTY(QString extraEnv READ extraEnv WRITE setExtraEnv NOTIFY extraEnvChanged)
    Q_PROPERTY(QString preStartScript READ preStartScript WRITE setPreStartScript NOTIFY preStartScriptChanged)
    Q_PROPERTY(bool serviceFileInstalled READ serviceFileInstalled NOTIFY serviceFileInstalledChanged)
    Q_PROPERTY(bool serviceRunning READ serviceRunning WRITE setServiceRunning NOTIFY serviceRunningChanged)

public:
    explicit ServiceControl(QObject *parent = 0);

    QString serviceName() const;
    void setServiceName(const QString &serviceName);
    QString appId() const;
    void setAppId(const QString &appId);
    QString servicePath() const;
    void setServicePath(const QString &servicePath);
    QString libraryPath() const;
    void setLibraryPath(const QString &libraryPath);
    QString extraEnv() const;
    void setExtraEnv(const QString &extraEnv);
    QString preStartScript() const;
    void setPreStartScript(const QString &preStartScript);

    bool serviceFileInstalled() const;
    Q_INVOKABLE bool installServiceFile();
    Q_INVOKABLE bool removeServiceFile();

    bool serviceRunning() const;
    bool setServiceRunning(bool running);
    Q_INVOKABLE bool startService();
    Q_INVOKABLE bool stopService();
    Q_INVOKABLE bool restartService();

signals:
    void serviceNameChanged();
    void appIdChanged();
    void servicePathChanged();
    void libraryPathChanged();
    void extraEnvChanged();
    void preStartScriptChanged();
    void serviceFileInstalledChanged();
    void serviceRunningChanged();

private:
    QString m_serviceName;
    QString m_appId;
    QString m_servicePath;
    QString m_libraryPath;
    QString m_extraEnv;
    QString m_preStartScript;
};

#endif // SERVICECONTROL_H
