#include <QDebug>

#include "linphone.h"

Linphone::Linphone() {
    connect(&m_linphoneProcess, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(linphoneProcessFinished(int, QProcess::ExitStatus)));

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
    args << "terminate";
    m_linphoneProcess.setProcessEnvironment(m_env);
    m_linphoneProcess.start(m_linphonecsh, args);

    qDebug() << "LINPHONECSH: terminating call";
}

void Linphone::answer() {
    QStringList args;
    args << "answer";
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
