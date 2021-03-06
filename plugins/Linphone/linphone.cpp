#include <QDebug>
#include <QSettings>

#include "linphone.h"

Linphone::Linphone() {
    connect(&m_linphoneProcess, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(linphoneProcessFinished(int, QProcess::ExitStatus)));
    connect(&m_linphoneProcess, SIGNAL(readyReadStandardOutput()), this, SIGNAL(readStatus()));

    m_env = QProcessEnvironment::systemEnvironment();
    m_env.insert("LD_LIBRARY_PATH", m_libPath);
    m_env.insert("TMPDIR", m_tmpdir);
}

void Linphone::call(QString address) {
    QStringList args;
    args << "dial" << address;
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: calling" << address;
}

void Linphone::terminate() {
    QStringList args;
    args << "generic" << "terminate";
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: terminating call" << &m_env;
}

void Linphone::answer() {
	//TODO Might it be needed to specify wich call?
    QStringList args;
    args << "generic" << "answer";
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: answering call";
}

void Linphone::mute() {
    QStringList args;
    args << "mute";
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: muting call";
}

void Linphone::unmute() {
    QStringList args;
    args << "unmute";
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: unmutting call";
}

void Linphone::registerSIP(QString user, QString domain, QString password) {
    QStringList args;
    QString userUser;
    QString domainHost;
    QString passwordPassword;
    //address = "sip:" + user + "@" + domain;
    userUser = " --username " + user;
    domainHost = " --host " + domain;
    passwordPassword = " --password " + password;
    args << "register" << "--username" << user << "--host" << domain << "--password" << password;
    qDebug() << "register" << "--username" << user << "--host" << domain;
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: registering " << user;

    status("register");
}

void Linphone::status(QString whatToCheck) {
    QStringList args;
    args << "status" << whatToCheck;

    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: status on " << whatToCheck;

}

QString Linphone::readStatusOutput() {

	QByteArray bytes = m_linphoneProcess.readAllStandardOutput();
    QString output = QString::fromLocal8Bit(bytes);

    qDebug() << "LINPHONECSH: output " << output;
    return output;
}

void Linphone::command(QStringList userCommand) {
    QStringList args;
    args << userCommand;

    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: command " << userCommand;

}

void Linphone::linphoneProcessFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    //Extra paranoid logging
    qDebug() << "LINPHONECSH: stdout" << m_linphoneProcess.readAllStandardOutput();
    qDebug() << "LINPHONECSH: stderr" << m_linphoneProcess.readAllStandardError();
    qDebug() << "LINPHONECSH: exit code" << m_linphoneProcess.exitCode();

    //More info http://doc.qt.io/qt-5/qprocess.html#ProcessError-enum
    if (m_linphoneProcess.error() == QProcess::FailedToStart) {
        qDebug() << "LINPHONECSH: error: QProcess::FailedToStart";
    }
    else if (m_linphoneProcess.error() == QProcess::Crashed) {
        qDebug() << "LINPHONECSH: error: QProcess::Crashed";
    }
    else if (m_linphoneProcess.error() == QProcess::Timedout) {
        qDebug() << "LINPHONECSH: error: QProcess::Timedout";
    }
    else if (m_linphoneProcess.error() == QProcess::WriteError) {
        qDebug() << "LINPHONECSH: error: QProcess::WriteError";
    }
    else if (m_linphoneProcess.error() == QProcess::ReadError) {
        qDebug() << "LINPHONECSH: error: QProcess::ReadError";
    }
    else {
        if (m_linphoneProcess.exitCode() == 0) {
            qDebug() << "LINPHONECSH: no errors running the process";
        }
        else {
            qDebug() << "LINPHONECSH: There was an unknown error";
        }
    }
}

void Linphone::setConfig(QString key, QString value) {
    QSettings settings(m_configFile, QSettings::IniFormat);
    settings.setValue(key, value);
}
