#ifndef __MESSAGES_H__
#define __MESSAGES_H__
#include <locale>

class Messages {
    std::locale loc;
    const std::messages<char>& facet;
    std::messages_base::catalog cat;
public:
    Messages(const std::string& LANG) : loc(LANG), facet(std::use_facet<std::messages<char>>(loc)) {
        cat = facet.open("walbrix", loc);
    }
    ~Messages() {
        facet.close(cat);
    }
    std::string operator()(const std::string& msg) { return facet.get(cat, 0, 0, msg); }
};

extern Messages MSG;

#endif // __MESSAGES_H__