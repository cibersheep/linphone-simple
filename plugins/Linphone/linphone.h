#ifndef LINPHONE_H
#define LINPHONE_H

#include <QObject>
#include <QProcess>

class Linphone: public QObject {
    Q_OBJECT

public:
    Linphone();
    ~Linphone() = default;

    Q_INVOKABLE void call(QString address);
    Q_INVOKABLE void terminate();
    Q_INVOKABLE void answer();
    Q_INVOKABLE void mute();
    Q_INVOKABLE void unmute();
    Q_INVOKABLE void registerSIP(QString user, QString domain, QString password);
    Q_INVOKABLE void status(QString whatToCheck);
    Q_INVOKABLE void command(QStringList userCommand);
    Q_INVOKABLE void setConfig(QString key, QString value);

Q_SIGNALS:
    void readStatus();

public Q_SLOTS:
    void linphoneProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    QString readStatusOutput();

private:
    //TODO don't hardcode these
    QString m_libPath = "/opt/click.ubuntu.com/linphone.cibersheep/current/linphone/lib/arm-linux-gnueabihf";
    QString m_linphonecsh = "/opt/click.ubuntu.com/linphone.cibersheep/current/linphone/bin/linphonecsh";
    QString m_tmpdir = "/home/phablet/.cache/linphone-tmp/";
    QString m_configFile = "/home/phablet/.linphonerc";

    QProcessEnvironment m_env;
    QProcess m_linphoneProcess;
};

#endif
