//Modified from http://bazaar.launchpad.net/~mzanetti/rockwork/trunk/view/head:/rockwork/servicecontrol.cpp

#include "servicecontrol.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>
#include <QProcess>

ServiceControl::ServiceControl(QObject *parent) : QObject(parent)
{

}

QString ServiceControl::serviceName() const
{
    return m_serviceName;
}

void ServiceControl::setServiceName(const QString &serviceName)
{
    if (m_serviceName != serviceName) {
        m_serviceName = serviceName;
        emit serviceNameChanged();
    }
}

QString ServiceControl::appId() const
{
    return m_appId;
}

void ServiceControl::setAppId(const QString &appId)
{
    if (m_appId != appId) {
        m_appId = appId;
        emit appIdChanged();
    }
}

QString ServiceControl::servicePath() const
{
    return m_servicePath;
}

void ServiceControl::setServicePath(const QString &servicePath)
{
    if (m_servicePath != servicePath) {
        m_servicePath = servicePath;
        emit servicePathChanged();
    }
}

QString ServiceControl::libraryPath() const
{
    return m_libraryPath;
}

void ServiceControl::setLibraryPath(const QString &libraryPath)
{
    if (m_libraryPath != libraryPath) {
        m_libraryPath = libraryPath;
        emit libraryPathChanged();
    }
}

QString ServiceControl::extraEnv() const
{
    return m_extraEnv;
}

void ServiceControl::setExtraEnv(const QString &extraEnv)
{
    if (m_extraEnv != extraEnv) {
        m_extraEnv = extraEnv;
        emit extraEnvChanged();
    }
}

QString ServiceControl::preStartScript() const
{
    return m_preStartScript;
}

void ServiceControl::setPreStartScript(const QString &preStartScript)
{
    if (m_preStartScript != preStartScript) {
        m_preStartScript = preStartScript;
        emit preStartScriptChanged();
    }
}

bool ServiceControl::serviceFileInstalled() const
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set.";
        return false;
    }
    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    return f.exists();
}

bool ServiceControl::installServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set. Cannot generate service file.";
        return false;
    }

    if (m_appId.isEmpty()) {
        qDebug() << "Service App ID not set. Cannot generate service file.";
        return false;
    }

    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    if (f.exists()) {
        qDebug() << "Service file already existing...";
        return false;
    }

    if (!f.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "Cannot create service file";
        return false;
    }

    QString appDir = qApp->applicationDirPath();
    // Try to replace version with "current" to be more robust against updates
    appDir.replace(QRegExp(m_appId.toUtf8() + "\/[0-9.]*\/"), m_appId.toUtf8() + "/current/");

    QString servicePath = m_servicePath;
    if (m_servicePath.isEmpty()) {
        servicePath = appDir.toUtf8() + "/" + m_serviceName.toUtf8();
    }

    QString libraryPath = m_libraryPath;
    if (m_libraryPath.isEmpty()) {
        libraryPath = appDir.toUtf8() + "/../";
    }

    f.write("start on started unity8\n");
    f.write("env LD_LIBRARY_PATH=" + libraryPath.toUtf8() + ":$LD_LIBRARY_PATH\n");
    if (!m_extraEnv.isEmpty()) {
        f.write(m_extraEnv.toUtf8() + "\n");
    }

    if (!m_preStartScript.isEmpty()) {
        f.write("pre-start script\n");
        f.write(m_preStartScript.toUtf8() + "\n");
        f.write("end script\n");
    }

    f.write("exec " + servicePath.toUtf8() + "\n");
    f.close();
    return true;
}

bool ServiceControl::removeServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set.";
        return false;
    }
    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    return f.remove();
}

bool ServiceControl::serviceRunning() const
{
    QProcess p;
    p.start("initctl", {"status", m_serviceName});
    p.waitForFinished();
    QByteArray output = p.readAll();
    qDebug() << output;
    return output.contains("running");
}

bool ServiceControl::setServiceRunning(bool running)
{
    if (running && !serviceRunning()) {
        return startService();
    } else if (!running && serviceRunning()) {
        return stopService();
    }
    return true; // Requested state is already the current state.
}

bool ServiceControl::startService()
{
    qDebug() << "should start service";
    int ret = QProcess::execute("start", {m_serviceName});
    return ret == 0;
}

bool ServiceControl::stopService()
{
    qDebug() << "should stop service";
    int ret = QProcess::execute("stop", {m_serviceName});
    return ret == 0;
}

bool ServiceControl::restartService()
{
    qDebug() << "should stop service";
    int ret = QProcess::execute("restart", {m_serviceName});
    return ret == 0;
}
