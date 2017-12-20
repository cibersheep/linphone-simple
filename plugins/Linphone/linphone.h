#ifndef LINPHONE_H
#define LINPHONE_H

#include <QObject>

class Linphone: public QObject {
    Q_OBJECT

public:
    Linphone();
    ~Linphone() = default;

    Q_INVOKABLE void call(QString address);
    Q_INVOKABLE void answer();
};

#endif
